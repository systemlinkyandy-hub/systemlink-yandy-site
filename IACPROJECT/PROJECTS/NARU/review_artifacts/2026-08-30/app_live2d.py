"""
app_live2d.py
=============
Noll VTuber AI - Live2D統合版

元の app.py に以下を追加:
  1. AvatarEngine（簡易Live2D）を起動
  2. speak() を speak_with_lipsync() に置き換えて口パク同期
  3. モード（AUTO/CHAT/DISCUSSION）はそのまま維持

変更箇所は「# [LIVE2D]」コメントで識別できる。
元の app.py の動作は一切変更していない。

動作環境:
  - Windows: os.startfile で音声再生
  - Linux: pygame.mixer で音声再生

起動方法:
  python app_live2d.py
"""

import requests
import json
import random
import time
import os
import queue
import threading
import asyncio
import re
import textwrap
import sys
import itertools

# TikTokLive はオプション（CHATモードでのみ使用）
# .venv に未インストールでも起動できるよう try/except で保護
try:
    from TikTokLive import TikTokLiveClient
    from TikTokLive.events import CommentEvent
    TIKTOK_AVAILABLE = True
except ImportError:
    print("[警告] TikTokLive が未インストールです。CHATモードのTikTok連携は無効になります。")
    print("       インストール: pip install TikTokLive")
    TikTokLiveClient = None
    CommentEvent = None
    TIKTOK_AVAILABLE = False

input_queue = queue.Queue()

# [QUEUE] コメント受信(input_queue)をLLM生成・TTS生成/再生から分離する。
# 直列ブロッキング解消: 各段はworkerスレッドが個別に処理し、
# メインループ(input_queue)がLLM/TTS待ちで止まらないようにする。
llm_queue = queue.Queue()
tts_queue = queue.Queue()
_job_id_gen = itertools.count(1)

# [LATENCY] job_idごとの区間計測ログ。playback_complete到達時に破棄する。
_job_stage_log = {}


def latency_log(job_id, stage):
    """job_idの各段階到達時刻を記録し、直前段階からの差分と合計経過を出力する。"""
    ts = time.perf_counter()
    history = _job_stage_log.setdefault(job_id, [])
    prev_ts = history[-1][1] if history else ts
    start_ts = history[0][1] if history else ts
    history.append((stage, ts))
    print(f"[LATENCY] job={job_id} stage={stage} +{ts - prev_ts:.3f}s total={ts - start_ts:.3f}s")
    if stage == "playback_complete":
        _job_stage_log.pop(job_id, None)

from dotenv import load_dotenv
from elevenlabs.client import ElevenLabs
from elevenlabs import VoiceSettings
from elevenlabs.types import PronunciationDictionaryLocator
from tts_dict import REPLACEMENTS
from prompts import (
    CHARACTER_PROMPT,
    COMMON_STYLE,
    CHAT_PROMPT,
    AUTO_PROMPT,
    DISCUSSION_PROMPT
)

# [LIVE2D] アバターエンジンと音声解析モジュールをインポート
from avatar_engine import AvatarEngine
from voice_analyzer import speak_with_lipsync, write_volume
from subtitle_scroller import start_scrollers, stop_scrollers

load_dotenv()

elevenlabs_client = ElevenLabs(api_key=os.getenv("ELEVENLABS_API_KEY"))

DEFAULT_VOICE = "fRxA2jEZb3d44a0gLaOc"  # Noll
ADMIN_VOICE   = "5ZvwsX5VVYw26p6hotQv"  # Kei
COMMENT_VOICE = "nMLAJvHm96aMWubKsf0q"  # Comment

# voice_id ごとの音声設定
# speed: 0.7=遅い 1.0=標準 1.2=速い
# stability: 0.0〜1.0（高いほど安定・単調）
# similarity_boost: 0.0〜1.0（高いほど声質に忠実）
# style: 0.0〜1.0（高いほど感情豊か）
VOICE_SETTINGS = {
    DEFAULT_VOICE: VoiceSettings(speed=1.0, stability=0.5, similarity_boost=0.75, style=0.0),
    ADMIN_VOICE:   VoiceSettings(speed=1.0, stability=0.5, similarity_boost=0.75, style=0.0),
    COMMENT_VOICE: VoiceSettings(speed=1.0, stability=0.5, similarity_boost=0.75, style=0.0),
}

# ElevenLabs 発音辞書（pronunciation_manager.py --setup で登録後に .env に自動保存される）
_DICT_ID  = os.getenv("ELEVENLABS_DICT_ID", "")
_DICT_VER = os.getenv("ELEVENLABS_DICT_VERSION_ID", "")
DICT_LOCATORS = (
    [PronunciationDictionaryLocator(
        pronunciation_dictionary_id=_DICT_ID,
        version_id=_DICT_VER,
    )]
    if _DICT_ID and _DICT_VER else None
)

from openai import OpenAI

client_ai = OpenAI()

# ===== Cost / safety defaults =====
# 起動しただけでは有料APIを呼ばない。
MODE = "standby"   # "standby" / "auto" / "chat" / "discussion"

# OpenAIの現行・低コストモデルを既定にする。
# 必要なら環境変数 OPENAI_MODEL で差し替え可能。
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-5.6-luna")

# CHATからAUTOへ勝手に戻らない。AUTOは A/ を明示入力した時だけ。
AUTO_RETURN_ENABLED = False

# 無操作時の勝手な発話を止める。
IDLE_TALK_ENABLED = False

# 視聴者コメント自体をElevenLabsで読み上げるとTTSがほぼ倍になるため既定OFF。
READ_COMMENTS_ALOUD = False

# 1セッションでElevenLabsへ送る文字数の安全上限。
# 0以下に設定すると無制限。既定3000文字で暴走を止める。
TTS_SESSION_CHAR_BUDGET = int(os.getenv("NARU_TTS_SESSION_BUDGET", "3000"))
tts_chars_used = 0

# AUTO↔CHAT 自動切り替え設定
# AUTOモード中にTikTokコメントが来るとCHATモードに自動切り替え
# CHATモードでこの秒数コメントがなければAUTOモードに自動復帰
AUTO_RETURN_TIMEOUT = 60   # 秒（この値を変えて調整）

conversation_memory = []
recent_auto_lines   = []
input_active        = False
is_speaking         = False
last_comment_time   = 0.0
last_auto_time      = 0.0
last_mode_label     = None

TIKTOK_USERNAME         = "zr6pkupk"   # @は不要
tiktok_client           = None
tiktok_listener_started = False

last_comment_user = ""
last_comment_text = ""

# [LIVE2D] アバターエンジンをグローバルに保持
avatar_engine = None


# ===== OBS書き込み =====
def format_subtitle(text, width=22):
    """字幕テキストを折り返す"""
    text = text.replace("\n", " ")
    sentences = text.split("。")
    lines = []
    for s in sentences:
        s = s.strip()
        if not s:
            continue
        wrapped = textwrap.wrap(s + "。", width=width)
        lines.extend(wrapped)
    return "\n".join(lines)

def write_subtitle(text):
    """OBS用字幕ファイルに書き込む"""
    with open("output/subtitle.txt", "w", encoding="utf-8") as f:
        f.write(text + "\n")

def write_comment(text):
    """OBS用コメントファイルに書き込む"""
    with open("output/comment.txt", "w", encoding="utf-8") as f:
        f.write("\n" + text + "\n")


# ===== コメント取得スレッド =====
def start_tiktok_listener():
    global tiktok_client, tiktok_listener_started

    # TikTokLive が未インストールの場合はスキップ
    if not TIKTOK_AVAILABLE:
        print("[TikTok] TikTokLive 未インストールのためスキップ。pip install TikTokLive で有効化できます。")
        return

    if tiktok_listener_started:
        return

    tiktok_listener_started = True
    tiktok_client = TikTokLiveClient(unique_id=TIKTOK_USERNAME)

    @tiktok_client.on(CommentEvent)
    async def on_comment(event: CommentEvent):
        global last_comment_user, last_comment_text

        user_name = event.user.nickname.strip()
        text = event.comment.strip()

        if not text:
            return

        # 同一コメントの連打を防ぐ
        if user_name == last_comment_user and text == last_comment_text:
            return

        last_comment_user = user_name
        last_comment_text = text

         # CHATまたはAUTOモードのときキューに流す（AUTOはCHATへ自動切り替えのため）
        if MODE in ("chat", "auto"):
            input_queue.put({
                "type": "tiktok_comment",
                "user": user_name,
                "text": text
            })
        print(f"\n[TikTok] {user_name}: {text}")

    def runner():
        try:
            tiktok_client.run()
        except Exception as e:
            print("TikTok listener error:", e)

    threading.Thread(target=runner, daemon=True).start()


# ===== Inputスレッド =====
def input_thread():
    global input_active

    while True:
        try:
            input_active = True
            user_input = input(f"\n[{MODE.upper()}] >> ").strip()
            input_queue.put({"type": "console", "text": user_input})

        except EOFError:
            break

        finally:
            input_active = False


# ===== Instruction =====
def build_instructions(mode):
    if mode == "chat":
        return CHARACTER_PROMPT + COMMON_STYLE + CHAT_PROMPT
    elif mode == "auto":
        return CHARACTER_PROMPT + COMMON_STYLE + AUTO_PROMPT
    elif mode == "discussion":
        return CHARACTER_PROMPT + COMMON_STYLE + DISCUSSION_PROMPT


# ===== AI CHATモード =====
def generate_ai_response(user_input: str, user_name: str = "") -> str:
    history = "\n".join(conversation_memory[-10:])
    name_line = f"コメントした相手: {user_name}\n" if user_name else ""

    response = client_ai.responses.create(
        model=OPENAI_MODEL,
        instructions=CHARACTER_PROMPT + COMMON_STYLE + CHAT_PROMPT,
        input=f"""
これまでの会話:
{history}

{name_line}視聴者コメント:
{user_input}

自然な会話として返答する。
前の流れを踏まえて答える。

【重要】
・相手が「挨拶して」「呼んで」「感謝して」「締めて」と頼んでいる時は、
  分析せず、その依頼をそのまま実行する
・コメントを受けて一言だけ感想を言い、そのあと少しだけ話を広げる
・日本語として自然に（不自然な言い回し禁止）
・詩的すぎない
・相手に二択の選択を迫らない
・問いかけで終わらない
""",
        max_output_tokens=200,
    )
    return response.output_text.strip()


# ===== AI AUTOモード =====
def generate_auto_talk():
    response = client_ai.responses.create(
        model=OPENAI_MODEL,
        instructions=build_instructions(MODE),
        input="""
今は配信中の自律発話。
自分の趣味についてとりとめなく話す

重要:
・都市伝説や、臨床心理学、心理学の雑学について長めに話す
・自然な会話
・難しくしない
・説明しすぎない
・優しさはあるが距離感も残す
・相手に二択の選択を迫らない
・問いかけで終わらない
""",
        max_output_tokens=500,
    )
    return response.output_text.strip()


# ===== 自己紹介 =====
def intro_noll():
    return """ナル、でいい。

よびやすいなら、
それでいい。"""


# ===== 発話ノーマライゼーション =====
def normalize_for_tts(text: str) -> str:
    text = re.sub(r"[。]+", "。", text)
    text = re.sub(r"[、]+", "、", text)
    text = text.replace("…", "")

    # 長いキーを先に処理することで部分一致の誤置換を防ぐ
    for k in sorted(REPLACEMENTS.keys(), key=len, reverse=True):
        text = text.replace(k, REPLACEMENTS[k])

    text = text.replace("……", '<break time="500ms" />')
    return text


# ===== 音声再生（Live2D口パク同期版） =====
def speak(text, voice_id=DEFAULT_VOICE, voice_settings=None, job_id=None):
    """
    ElevenLabsで音声を生成・再生し、
    同時にアバターの口パクを同期させる。

    [LIVE2D] 元の speak() から以下を変更:
      - speak_with_lipsync() を呼び出して口パク同期
      - avatar_engine を渡して直接音量を設定

    job_id が指定された場合、tts_request_start / tts_audio_ready /
    playback_start / playback_complete を latency_log() へ記録する。
    """
    global is_speaking, tts_chars_used
    if not text:
        return False

    # ElevenLabsの従量課金暴走を止める。
    estimated_chars = len(normalize_for_tts(text))
    if TTS_SESSION_CHAR_BUDGET > 0 and (tts_chars_used + estimated_chars) > TTS_SESSION_CHAR_BUDGET:
        print(
            f"[COST GUARD] TTS session budget reached: "
            f"{tts_chars_used}/{TTS_SESSION_CHAR_BUDGET} chars. 音声生成を停止します。"
        )
        return False

    tts_chars_used += estimated_chars
    print(f"[COST] TTS chars: {tts_chars_used}/{TTS_SESSION_CHAR_BUDGET}")

    is_speaking = True
    try:
        vs = voice_settings or VOICE_SETTINGS.get(voice_id)
        result = speak_with_lipsync(
            text=text,
            voice_id=voice_id,
            elevenlabs_client=elevenlabs_client,
            avatar_engine=avatar_engine,    # [LIVE2D] アバターエンジンを渡す
            normalize_fn=normalize_for_tts,
            voice_settings=vs,
            dict_locators=DICT_LOCATORS,
            job_id=job_id,
            on_stage=(lambda jid, stage, ts: latency_log(jid, stage)) if job_id is not None else None,
        )
        return result

    except Exception as e:
        print("音声エラー:", e)
        write_volume(0.0)  # [LIVE2D] エラー時は音量をリセット
        return False

    finally:
        is_speaking = False


# ===== Chat =====
def generate_chat_idle_talk():
    response = client_ai.responses.create(
        model=OPENAI_MODEL,
        instructions=build_instructions(MODE),
        input="""
配信中に30秒ほどコメントが止まっている。
会話をつなぐために、自然な雑談を3〜4センテンスで話して。
""",
        max_output_tokens=350,
    )
    return response.output_text.strip()


# ===== Chat speak =====
def speak_chat_comment(user_name, text):
    comment_text = f"{user_name}。{text}"
    return speak(comment_text, voice_id=COMMENT_VOICE, voice_settings=VOICE_SETTINGS.get(COMMENT_VOICE))


# ===== [QUEUE] LLM生成worker =====
def llm_worker():
    """
    llm_queueからjobを受け取りLLM応答を生成する専用スレッド。
    ここが詰まってもinput_queueの受信(メインループ)は止まらない。
    """
    while True:
        job = llm_queue.get()
        try:
            latency_log(job["id"], "llm_request_start")
            response_text = generate_ai_response(job["text"], user_name=job["user"])
            latency_log(job["id"], "llm_text_ready")
            job["response_text"] = response_text
            tts_queue.put(job)
        except Exception as e:
            print(f"[llm_worker] エラー (job={job['id']}):", e)
        finally:
            llm_queue.task_done()


# ===== [QUEUE] TTS生成/再生worker =====
def tts_worker():
    """
    tts_queueからjobを受け取りTTS生成・再生を行う専用スレッド。
    LLM生成(llm_worker)とは別スレッドのため、次のLLM応答生成を待たせない。
    """
    while True:
        job = tts_queue.get()
        try:
            response_text = job["response_text"]
            conversation_memory.append(f"Noll: {response_text}")
            print("Noll:", response_text)
            write_subtitle(response_text)
            speak(response_text, job_id=job["id"])
            show_prompt()
        except Exception as e:
            print(f"[tts_worker] エラー (job={job['id']}):", e)
        finally:
            tts_queue.task_done()


# ===== discussion =====
def speak_comment(user_name, text):
    comment_text = f"{user_name}。{text}"
    return speak(comment_text, voice_id=ADMIN_VOICE, voice_settings=VOICE_SETTINGS.get(ADMIN_VOICE))


# ===== モード切替 =====
def handle_mode_switch(cmd: str):
    global MODE, last_comment_time, last_auto_time

    if cmd in ("S/", "/S"):
        MODE = "standby"
        last_comment_time = time.time()
        last_auto_time = time.time()
        print("→ STANDBY")
        show_prompt()
        return True

    if cmd in ("A/", "/A"):
        MODE = "auto"
        last_comment_time = time.time()
        last_auto_time = time.time()
        print("→ AUTO")
        show_prompt()
        return True

    if cmd in ("C/", "/C"):
        MODE = "chat"
        last_comment_time = time.time()
        last_auto_time = time.time()
        print("→ CHAT")
        show_prompt()
        return True

    if cmd in ("D/", "/D"):
        MODE = "discussion"
        last_comment_time = time.time()
        last_auto_time = time.time()
        print("→ DISCUSSION")
        show_prompt()
        return True

    return False


def show_prompt():
    mode_label = MODE.upper()
    print(f"\n[{mode_label}] >> ", end="", flush=True)


def handle_user_comment(user_input: str):
    global last_comment_time, last_auto_time

    now = time.time()
    last_comment_time = now
    last_auto_time = now

    conversation_memory.append(user_input)
    write_comment(user_input)

    if MODE == "discussion":
        speak_comment(user_input)

    text = generate_ai_response(user_input)
    conversation_memory.append(f"Noll: {text}")
    print("Noll:", text)
    write_subtitle(text)
    speak(text)
    show_prompt()


# ===== メイン =====
if __name__ == "__main__":
    print("=== 配信AI Live2D版 起動 ===")

    # [MODEL] OPENAI_MODELの実在確認（起動時1回のみ、メタデータ取得のみでトークン課金なし）。
    # 実在確認できないモデルIDはsilent fallbackせず、ここで起動を止める。
    try:
        client_ai.models.retrieve(OPENAI_MODEL)
        print(f"[SAFE] OPENAI_MODEL 実在確認OK: {OPENAI_MODEL}")
    except Exception as e:
        print(f"[FATAL] OPENAI_MODEL の実在確認に失敗しました: {OPENAI_MODEL!r}")
        print(f"        {e}")
        print("        .env の OPENAI_MODEL を確認してください。silent fallbackはしません。起動を中止します。")
        sys.exit(1)

    # [LIVE2D] アバターエンジンを起動
    # SAFE v2: 前回終了時の volume.txt が残っていても口パクしないよう、
    # エンジン起動前後で音量を必ず 0 に戻す。
    print("[LIVE2D] アバターエンジンを起動中...")
    write_volume(0.0)
    avatar_engine = AvatarEngine()
    avatar_engine.start()
    time.sleep(1.0)  # ウィンドウが開くまで少し待つ
    write_volume(0.0)
    # [SCROLLER] OBS用1行スクローラーを起動
    start_scrollers()

    # SAFE START: 起動直後は無発話。ここではOpenAI/ElevenLabsを一切呼ばない。
    print("[SAFE] STANDBYで起動しました。起動だけでは有料APIを呼びません。")
    print("[SAFE] C/=CHAT  D/=DISCUSSION  A/=AUTO(有料・自律発話)  S/=STANDBY")
    write_subtitle("NARU STANDBY")
    write_comment("")
    show_prompt()

    now = time.time()
    last_comment_time = now
    last_auto_time = now

    # Inputスレッド起動
    t = threading.Thread(target=input_thread, daemon=True)
    t.start()

    # [QUEUE] LLM/TTS workerスレッド起動。
    # メインループ(input_queue)はここから先、LLM/TTS/再生の完了を待たない。
    threading.Thread(target=llm_worker, daemon=True).start()
    threading.Thread(target=tts_worker, daemon=True).start()

    # ===== メインループ =====
    while True:
        now = time.time()

        if not input_queue.empty():
            item = input_queue.get()
            item_type = item.get("type", "")
            text = item.get("text", "").strip()

            # コンソール入力のモード切替
            if item_type == "console":
                cmd = text.upper()

                if cmd in ["S/", "/S"]:
                    MODE = "standby"
                    write_volume(0.0)
                    print("→ STANDBY（有料API自動発話なし）")
                    continue

                elif cmd in ["A/", "/A"]:
                    MODE = "auto"
                    last_auto_time = time.time()
                    print("→ AUTO（5分ごとに有料APIを使用）")
                    continue

                elif cmd in ["C/", "/C"]:
                    MODE = "chat"
                    print("→ CHAT")
                    start_tiktok_listener()
                    continue

                elif cmd in ["D/", "/D"]:
                    MODE = "discussion"
                    print("→ DISCUSSION")
                    continue

              # ===== CHAT / AUTO→CHAT自動切り替え: TikTokコメント自動応答 =====
            if item_type == "tiktok_comment" and MODE in ("chat", "auto"):
                # AUTOモード中にコメントが来たらCHATに自動切り替え
                if MODE == "auto":
                    MODE = "chat"
                    print(f"\n[自動] AUTO → CHAT（コメント検知）")
                user_name  = item.get("user", "リスナー")
                user_input = text
                conversation_memory.append(f"{user_name}: {user_input}")
                last_comment_time = time.time()
                write_comment(f"{user_name}: {user_input}")

                job_id = next(_job_id_gen)
                latency_log(job_id, "comment_received")

                # [QUEUE] LLM生成・TTS生成/再生はworkerスレッドへ委譲する。
                # ここではjobを渡すだけで、メインループ(input_queueの受信)は待たない。
                # 既存の応急安全化(READ_COMMENTS_ALOUD既定OFF)は変更しない。
                # READ_COMMENTS_ALOUDが有効な場合のコメント読み上げは今回のスコープ外
                # (直列ブロッキング解消の対象外、既定OFFのため実害なし)。
                if READ_COMMENTS_ALOUD:
                    speak_chat_comment(user_name, user_input)
                llm_queue.put({"id": job_id, "user": user_name, "text": user_input})

            # ===== DISCUSSION: 手入力で深掘り =====
            elif item_type == "console" and MODE == "discussion" and text:
                user_input = text

                conversation_memory.append(f"Kei: {user_input}")
                last_comment_time = time.time()

                write_comment(user_input)

                response = client_ai.responses.create(
                    model=OPENAI_MODEL,
                    instructions=CHARACTER_PROMPT + COMMON_STYLE + DISCUSSION_PROMPT,
                    input=f"""
    これまでの会話:
    {chr(10).join(conversation_memory[-10:])}

    テーマ:
    {user_input}

    この話題を少し深掘りして、わかりやすく話す。
    """,
                    max_output_tokens=220,
                )

                text_out = response.output_text.strip()
                conversation_memory.append(f"Noll: {text_out}")

                print("Noll:", text_out)
                write_subtitle(text_out)
                speak(text_out)

            # ===== AUTO中の手入力コメント =====
            elif item_type == "console" and MODE == "auto" and text:
                print("(AUTOモード中)")

        if is_speaking:
            time.sleep(0.2)
            continue

        # ===== CHAT→AUTO 自動復帰 =====
        # CHATモードでAUTO_RETURN_TIMEOUT秒以上コメントがなければAUTOに戻る
        if AUTO_RETURN_ENABLED and MODE == "chat" and (now - last_comment_time) > AUTO_RETURN_TIMEOUT:
            MODE = "auto"
            last_auto_time = now
            print(f"\n[自動] CHAT → AUTO（{AUTO_RETURN_TIMEOUT}秒間コメントなし）")

        # AUTO: 5分ごとに自動発話
        if MODE == "auto" and (now - last_auto_time) > 300:
            print("AUTO TALK")
            line = generate_auto_talk()
            conversation_memory.append(f"Noll: {line}")
            print("Noll:", line)
            write_subtitle(line)
            speak(line)
            show_prompt()
            last_auto_time = time.time()

        # CHAT/DISCUSSION: 10分コメントなしでアイドルトーク
        elif IDLE_TALK_ENABLED and MODE in ["chat", "discussion"] and (now - last_comment_time) > 600:
            print("INTERVAL TALK")
            line = generate_chat_idle_talk()
            conversation_memory.append(f"Noll: {line}")
            print("Noll:", line)
            write_subtitle(line)
            speak(line)
            show_prompt()
            last_comment_time = time.time()
            last_auto_time = time.time()

        time.sleep(0.2)
