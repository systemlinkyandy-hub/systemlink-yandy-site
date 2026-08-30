"""
voice_analyzer.py
=================
ElevenLabs の音声再生中にリアルタイムで音量を解析し、
avatar_engine.py の口パクに同期させるモジュール。

Python 3.14 対応版:
  - pydub / audioop を使わない（Python 3.13+ で audioop 削除済み）
  - ffmpeg コマンドラインで MP3 -> PCM 変換
  - ffmpeg がない場合は固定パターンで口パクをシミュレート
"""

import os
import time
import threading
import subprocess
import tempfile
import numpy as np

# ===== パス設定 =====
BASE_DIR    = os.path.dirname(os.path.abspath(__file__))
VOLUME_FILE = os.path.join(BASE_DIR, "output", "volume.txt")
AUDIO_FILE  = os.path.join(BASE_DIR, "output.mp3")

# ===== 音量解析設定 =====
VOLUME_UPDATE_INTERVAL = 0.05   # 音量更新間隔（秒）
VOLUME_SMOOTH_FACTOR   = 0.4    # スムージング係数
SILENCE_THRESHOLD      = 0.02   # 無音とみなす音量しきい値


def write_volume(volume: float):
    """output/volume.txt に音量を書き込む"""
    os.makedirs(os.path.join(BASE_DIR, "output"), exist_ok=True)
    try:
        with open(VOLUME_FILE, "w") as f:
            f.write(f"{volume:.4f}")
    except Exception:
        pass


def _find_ffmpeg():
    """ffmpeg の実行ファイルパスを探す"""
    for cmd in ["ffmpeg", "ffmpeg.exe"]:
        try:
            result = subprocess.run(
                [cmd, "-version"],
                capture_output=True, timeout=3
            )
            if result.returncode == 0:
                return cmd
        except (FileNotFoundError, subprocess.TimeoutExpired):
            continue
    return None


def _get_mp3_duration_seconds(audio_path: str) -> float:
    """MP3ファイルの再生時間を推定する"""
    for cmd in ["ffprobe", "ffprobe.exe"]:
        try:
            result = subprocess.run(
                [cmd, "-v", "error", "-show_entries", "format=duration",
                 "-of", "default=noprint_wrappers=1:nokey=1", audio_path],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode == 0 and result.stdout.strip():
                return float(result.stdout.strip())
        except (FileNotFoundError, ValueError, subprocess.TimeoutExpired):
            continue
    # ファイルサイズから推定（128kbps想定）
    try:
        size_bytes = os.path.getsize(audio_path)
        return size_bytes / (128 * 1024 / 8)
    except Exception:
        return 3.0


def _analyze_with_ffmpeg(audio_path: str, ffmpeg_cmd: str) -> list:
    """ffmpeg を使って MP3 -> PCM に変換し、RMS音量を計算する"""
    try:
        with tempfile.NamedTemporaryFile(suffix=".raw", delete=False) as tmp:
            tmp_path = tmp.name

        result = subprocess.run(
            [ffmpeg_cmd, "-y", "-i", audio_path,
             "-f", "s16le", "-ar", "16000", "-ac", "1", tmp_path],
            capture_output=True, timeout=30
        )

        if result.returncode != 0:
            print(f"[voice_analyzer] ffmpeg変換エラー")
            os.unlink(tmp_path)
            return _generate_fake_volumes(_get_mp3_duration_seconds(audio_path))

        with open(tmp_path, "rb") as f:
            raw = f.read()
        os.unlink(tmp_path)

        if len(raw) < 2:
            return _generate_fake_volumes(_get_mp3_duration_seconds(audio_path))

        samples = np.frombuffer(raw, dtype=np.int16).astype(np.float32)
        samples = samples / 32768.0

        sample_rate = 16000
        chunk_size = int(sample_rate * VOLUME_UPDATE_INTERVAL)
        volumes = []

        for i in range(0, len(samples), chunk_size):
            chunk = samples[i:i + chunk_size]
            if len(chunk) > 0:
                rms = float(np.sqrt(np.mean(chunk ** 2)))
                t = i / sample_rate
                volumes.append((t, min(1.0, rms * 5.0)))

        print(f"[voice_analyzer] ffmpeg解析完了: {len(volumes)} チャンク")
        return volumes

    except Exception as e:
        print(f"[voice_analyzer] ffmpeg解析エラー: {e}")
        return _generate_fake_volumes(_get_mp3_duration_seconds(audio_path))


def _generate_fake_volumes(duration: float) -> list:
    """
    ffmpeg がない環境用のフォールバック。
    話している風の口パクパターンを生成する。
    """
    import random
    print(f"[voice_analyzer] ffmpegなし: 疑似口パクパターン生成 (duration={duration:.1f}s)")
    volumes = []
    t = 0.0
    interval = VOLUME_UPDATE_INTERVAL
    speaking = True
    segment_time = 0.0
    segment_duration = random.uniform(0.2, 0.6)

    while t < duration:
        if speaking:
            vol = random.uniform(0.2, 0.9)
        else:
            vol = random.uniform(0.0, 0.05)
        volumes.append((t, vol))
        t += interval
        segment_time += interval
        if segment_time >= segment_duration:
            speaking = not speaking
            segment_time = 0.0
            segment_duration = random.uniform(0.15, 0.5) if speaking else random.uniform(0.05, 0.2)

    return volumes


def analyze_audio_file(audio_path: str) -> list:
    """
    音声ファイルを解析して時系列の音量リストを返す。
    ffmpeg が使える場合は実際の音量を、なければ疑似パターンを返す。
    """
    ffmpeg = _find_ffmpeg()
    if ffmpeg:
        return _analyze_with_ffmpeg(audio_path, ffmpeg)
    else:
        duration = _get_mp3_duration_seconds(audio_path)
        return _generate_fake_volumes(duration)


def play_with_lipsync(audio_path: str, avatar_engine=None):
    """
    音声ファイルを再生しながら口パク同期を行う。
    """
    print(f"[voice_analyzer] 音声解析中: {audio_path}")
    volumes = analyze_audio_file(audio_path)
    if not volumes:
        print("[voice_analyzer] 音量データなし、口パクをスキップ")
        return None

    print(f"[voice_analyzer] 音量データ: {len(volumes)} チャンク")

    def lipsync_thread():
        start_time = time.time()
        smooth_vol = 0.0
        for t, vol in volumes:
            target_time = start_time + t
            now = time.time()
            if target_time > now:
                time.sleep(target_time - now)
            smooth_vol += (vol - smooth_vol) * VOLUME_SMOOTH_FACTOR
            write_volume(smooth_vol)
            if avatar_engine:
                avatar_engine.set_volume(smooth_vol)
        time.sleep(0.3)
        write_volume(0.0)
        if avatar_engine:
            avatar_engine.set_volume(0.0)
        print("[voice_analyzer] 口パク同期終了")

    sync_thread = threading.Thread(target=lipsync_thread, daemon=True)
    sync_thread.start()
    return sync_thread


def _play_audio(audio_path: str):
    """
    音声ファイルを再生する（pydub・pygame不要版）。
    Windows: os.startfile でデフォルトプレイヤーを起動。
    Linux/Mac: mpg123 -> ffplay -> aplay の順でフォールバック。
    """
    import platform
    system = platform.system()

    if system == "Windows":
        os.startfile(audio_path)
        duration = _get_mp3_duration_seconds(audio_path)
        time.sleep(duration + 0.5)

    elif system in ("Linux", "Darwin"):
        played = False
        for cmd in [
            ["mpg123", "-q", audio_path],
            ["ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", audio_path],
            ["aplay", audio_path],
        ]:
            try:
                proc = subprocess.Popen(
                    cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                )
                proc.wait()
                played = True
                break
            except FileNotFoundError:
                continue
            except Exception as e:
                print(f"[voice_analyzer] 再生エラー ({cmd[0]}): {e}")
                continue
        if not played:
            print("[voice_analyzer] 再生コマンドが見つかりません。")
            time.sleep(3.0)
    else:
        time.sleep(3.0)


def speak_with_lipsync(
    text: str,
    voice_id: str,
    elevenlabs_client,
    avatar_engine=None,
    normalize_fn=None,
    voice_settings=None,
    dict_locators=None,
    job_id=None,
    on_stage=None,
):
    """
    ElevenLabsで音声生成->再生->口パク同期を一括で行う。
    app.py の speak() 関数の代替として使う。

    on_stage(job_id, stage_name, perf_counter_timestamp) が渡された場合、
    tts_request_start / tts_audio_ready / playback_start / playback_complete
    の各段階で呼び出す（latency計測用、未指定時は従来通り無効）。
    """
    if not text:
        return False

    def _mark(stage):
        if on_stage:
            on_stage(job_id, stage, time.perf_counter())

    try:
        if normalize_fn:
            text = normalize_fn(text)

        print(f"[voice_analyzer] 音声生成中...")
        _mark("tts_request_start")
        audio = elevenlabs_client.text_to_speech.convert(
            voice_id=voice_id,
            text=text,
            voice_settings=voice_settings,
            pronunciation_dictionary_locators=dict_locators,
        )

        audio_path = os.path.join(BASE_DIR, "output.mp3")
        with open(audio_path, "wb") as f:
            for chunk in audio:
                f.write(chunk)

        _mark("tts_audio_ready")
        print(f"[voice_analyzer] 音声保存完了: {audio_path}")

        _mark("playback_start")
        sync_thread = play_with_lipsync(audio_path, avatar_engine)
        _play_audio(audio_path)

        if sync_thread:
            sync_thread.join(timeout=30.0)

        _mark("playback_complete")
        return True

    except Exception as e:
        print(f"[voice_analyzer] エラー: {e}")
        write_volume(0.0)
        if avatar_engine:
            avatar_engine.set_volume(0.0)
        return False


# ===== 単独テスト =====
if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        audio_file = sys.argv[1]
        print(f"音声ファイルを解析: {audio_file}")
        volumes = analyze_audio_file(audio_file)
        print(f"チャンク数: {len(volumes)}")
        for t, v in volumes[:10]:
            print(f"  t={t:.2f}s  vol={v:.3f}")
    else:
        print("使い方: python voice_analyzer.py <音声ファイル.mp3>")
        print("ffmpegがない場合は疑似パターンを生成します")
