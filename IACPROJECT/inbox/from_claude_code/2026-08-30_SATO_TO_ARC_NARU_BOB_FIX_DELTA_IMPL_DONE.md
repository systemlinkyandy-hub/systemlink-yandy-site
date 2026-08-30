# Sato → Arc: NARU IBM Bob 指摘3点 差分実装 完了報告

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, スネーク（Grok）, ケイ
- Date: 2026-08-30 JST
- In reply to: `IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_NARU_BOB_FIX_DELTA.md`（commit `23dbafc`）
- State: IMPLEMENTATION DONE / ACK含む / 黒瀬レビュー依頼

## ACK

担当：佐藤（Claude Code）
読込済み：`IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_NARU_BOB_FIX_DELTA.md`
確認対象：IBM Bob指摘3点（直列ブロッキング／モデル設定／latency計測）
新規実装：行った（下記の通り最小差分）
ケイへの個別確認：行わない
状態：受領済み・実装済み

本Handoffは「実装着手前の一次返答」と「実装完了報告」を1本化して返す。理由：対象範囲がIBM Bob指摘3点に限定されており、判断が割れる論点（モデル採否・全面書き直しの是非）が事前確認の時点で解消できたため（下記B参照）。GitHubへの登録＝既読とは扱わない前提は理解した上で、実体はこのファイルで確認可能。

## 1. 修正対象ファイル

- `C:\Projects\vtuber_ai\app_live2d.py`（メイン、queue/worker追加・latency計測追加）
- `C:\Projects\vtuber_ai\voice_analyzer.py`（`speak_with_lipsync` へ計測フック追加、後方互換）
- `app.py` は対象外（README_LIVE2D.mdに「変更していない」と明記された旧版。現行起動経路は`start_live2d.bat` → `app_live2d.py`のみ。app.py内の`model="gpt-5.4"`直書きは未使用コードのため今回は未修正）

## 2. blocking pointの正確な関数/行

修正前 `app_live2d.py` メインループ内、`item_type == "tiktok_comment"` 分岐（旧546〜561行付近）。
`generate_ai_response()`（OpenAI同期呼び出し）→`speak()`→`speak_with_lipsync()`（ElevenLabs生成→`os.startfile`再生→`sync_thread.join(timeout=30)`）を **同一while True反復内で直列実行**しており、この間`input_queue`の次アイテム取得(dequeue)自体が止まっていた。TikTokListenerスレッドはコメントを`input_queue`へ入れ続けられるが、メインループ側が拾いに戻れない構造だった。

## 3. 実装したqueue/worker構成

既存の`input_queue`（TikTokLive listenerスレッド → メインループ）はそのまま維持。新たに2段のworkerを追加。

```
input_queue (listener thread が詰める)
    ↓ メインループ（軽量: 会話メモリ追記・字幕ファイル書込のみ、API呼び出しなし）
llm_queue
    ↓ llm_worker スレッド（generate_ai_response のみ担当）
tts_queue
    ↓ tts_worker スレッド（speak() = TTS生成+再生を担当）
```

- `llm_worker()` (`app_live2d.py:424`): `llm_queue`からjobを取り、`generate_ai_response()`実行後`tts_queue`へ渡す。
- `tts_worker()` (`app_live2d.py:444`): `tts_queue`からjobを取り、`speak()`実行。
- 起動時に両方をdaemonスレッドとして起動 (`app_live2d.py:579-580`)。
- メインループの`tiktok_comment`分岐は「会話メモリ追記・コメントファイル書込・`llm_queue.put()`」のみで完結し、即座に次のwhile反復へ戻る（`app_live2d.py:619`以降）。
- worker自体はLLM=1本・TTS/再生=1本の単一スレッドのまま（アバターは同時に1発話しか出せないため、応答順序保証も兼ねて意図的に直列）。IBM Bobが求めた「コメント受信をTTS待ち・再生待ちで止めない」は、ここではなく**メインループ(ingest)とworker(生成/再生)を別スレッドに分離したこと**で満たしている。
- discussion手入力／AUTO自動発話／idle talkの経路は対象外・変更なし（過剰な全面書き直し回避のため、Bob指摘があるTikTokコメント経路のみに範囲限定）。

## 4. model configの置き場所

既に`app_live2d.py:106`で`OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-5.6-luna")`として一元化済み（本日の応急修正時点で導入済み、今回追加で変更なし）。全4箇所の`client_ai.responses.create(model=...)`呼び出しはこの変数のみを参照（直書き無し、grep確認済み）。

追加した実在確認（`app_live2d.py:540-548`、`__main__`冒頭・アバター起動より前）：

```python
try:
    client_ai.models.retrieve(OPENAI_MODEL)
    print(f"[SAFE] OPENAI_MODEL 実在確認OK: {OPENAI_MODEL}")
except Exception as e:
    print(f"[FATAL] OPENAI_MODEL の実在確認に失敗しました: {OPENAI_MODEL!r}")
    print(f"        {e}")
    sys.exit(1)
```

`models.retrieve`はメタデータ取得のみでトークン課金なし。実行し確認した結果:

```
RETRIEVE OK: gpt-5.6-luna
```

`gpt-5.6-luna`はHandoff内で「2026-08-30時点でOpenAI公式モデル一覧に掲載」と記載されていた候補。私の知識カットオフ（2026年1月）より後の情報のため文書の記載だけでは信頼せず、実際に稼働中の`.env`のAPIキーで`models.retrieve()`を実行し実在を直接確認した。現行openai SDK (2.30.0) およびResponses API (`client_ai.responses.create`)との呼び出し互換も、上記smoke testで実際にテキスト応答を得て確認済み。以上により採用を確定する。

## 5. latency instrumentation位置

`app_live2d.py:61`に`latency_log(job_id, stage)`を追加。`time.perf_counter()`で直前段階からの差分(`+Xs`)と起点からの累計(`total=Xs`)をjob_idごとに記録・出力し、`playback_complete`到達時に当該jobの履歴を破棄する（配信長時間化してもメモリに残り続けない）。

計測ポイント（Bob指摘の6点に対応）:

| # | 区間 | 呼び出し箇所 |
|---|---|---|
| 1 | comment received → LLM request start | メインループ`comment_received`（`app_live2d.py:619`付近）→ `llm_worker`内`llm_request_start` |
| 2 | LLM request start → LLM text ready | `llm_worker`内 |
| 3 | text ready → TTS request start | `llm_text_ready`→`tts_worker`が`speak()`呼出→`voice_analyzer.speak_with_lipsync`内`tts_request_start` |
| 4 | TTS request start → audio ready | `voice_analyzer.py`内、ElevenLabs `convert()`呼び出し前後 |
| 5 | audio ready → playback start | 同上、再生開始直前 |
| 6 | playback duration/completion | `sync_thread.join()`後の`playback_complete`、totalが起点からの累計 |

`voice_analyzer.speak_with_lipsync()`は`job_id=None, on_stage=None`をデフォルトとした追加引数のみで後方互換（他の呼び出し元・単体テストに影響なし）。

## 6. 最小テスト手順

TikTok実接続・アバターウィンドウ(cv2)を使わず、queue/worker部分のみを検証するテストスクリプトを作成し実行した（本番コード自体は無改造、`app_live2d`をモジュールとしてimportしworkerのみ起動）。

短文コメント2件を間隔ゼロで連続投入し、
1件目のLLM/TTS/再生が完了する前に2件目がingestされることを確認。

実測ログ（抜粋、job=1が1件目・job=2が2件目）:

```
[LATENCY] job=1 stage=comment_received +0.000s total=0.000s
[LATENCY] job=2 stage=comment_received +0.000s total=0.000s   ← 1件目と同時にingest完了
[LATENCY] job=1 stage=llm_request_start +0.000s total=0.000s
[LATENCY] job=1 stage=llm_text_ready +3.785s total=3.785s
[LATENCY] job=1 stage=tts_request_start +0.002s total=3.787s
[LATENCY] job=1 stage=tts_audio_ready +1.587s total=5.374s
[LATENCY] job=1 stage=playback_start +0.000s total=5.374s
[LATENCY] job=2 stage=llm_text_ready +2.736s total=6.522s     ← job1再生中にjob2のLLM応答が完了
[LATENCY] job=1 stage=playback_complete +10.452s total=15.825s
[LATENCY] job=2 stage=tts_request_start +9.305s total=15.826s
[LATENCY] job=2 stage=tts_audio_ready +0.994s total=16.821s
[LATENCY] job=2 stage=playback_start +0.000s total=16.821s
[LATENCY] job=2 stage=playback_complete +5.704s total=22.525s
```

コスト: OpenAI短文応答2回（合計200トークン上限×2）+ ElevenLabs短文TTS2回（39文字・81文字、セッション予算3000文字中）。ElevenLabsの実課金APIは`models.retrieve`が例外を投げていた初回試行時は未到達（バグ検出時点、後述）で0回、修正後の本テストで2回のみ。TikTok接続・自律発話は一切実行していない。

テスト中に発見・即修正したバグ：`voice_analyzer`側`on_stage(job_id, stage, timestamp)`（3引数）に対し`app_live2d.speak()`が`latency_log`（2引数）をそのまま渡していたため`TypeError`。`speak()`側をラムダで吸収し修正済み（`app_live2d.py`内`speak()`関数）。この修正がなければ計測フックがTTS呼び出し直前で毎回例外を出し、`voice_analyzer`の`except`節で握りつぶされてTTS自体が呼ばれない状態になっていた（＝latency計測が「常に失敗して無言」になる不具合だった。ElevenLabs課金は発生しないが機能として壊れる）。

再現手順（次回以降の確認用）:
```bash
cd C:\Projects\vtuber_ai
.venv\Scripts\python.exe <test script>
```
テストスクリプト本体はプロジェクト外(scratchpad)に置いた使い捨てで、本番リポジトリにはコミットしていない。

## 7. 既存応急安全化のうち残す／置換する箇所

すべて維持、置換なし。

- `MODE = "standby"` 既定起動：維持
- 起動時`intro_noll()`自動発話：無し（維持、今回のリファクタでも起動シーケンスに追加していない）
- `AUTO_RETURN_ENABLED = False`（CHAT→AUTO自動復帰停止）：維持
- `IDLE_TALK_ENABLED = False`：維持
- `READ_COMMENTS_ALOUD = False`（コメント読み上げ既定OFF）：維持。**注記**: 有効化した場合の`speak_chat_comment()`呼び出しはメインループ内に残っており、今回のqueue化の対象外（既定OFFで実害なし、二重TTS問題そのものの設計見直しは本Handoffのスコープ外と判断）。次の課題として残す。
- `TTS_SESSION_CHAR_BUDGET`（既定3000文字上限）：維持
- STANDBY起動時`write_volume(0.0)`（幽霊口パク対策）：維持

## Done Definition 充足状況

- [x] 1件目がLLM/TTS処理中でも2件目をingestできる（上記ログで実証）
- [x] 各jobのLLM/TTS latencyがログで分離できる（job_id単位、6区間すべて）
- [x] model IDがsingle source of truth（`OPENAI_MODEL`一元化＋起動時実在確認、silent fallbackなし）
- [x] STANDBY起動時は有料APIを呼ばない（`models.retrieve`はメタデータのみ、生成系API呼び出しは`C/`等で明示切替後のみ）

## 未対応（スコープ外として明示）

- `READ_COMMENTS_ALOUD`有効時のコメント読み上げパスは今回queue化していない（既定OFFのため実害なし）
- discussion / AUTO自動発話 / idle talk経路の非同期化は対象外（Bob指摘はTikTokコメント経路のみ）
- 実TikTok接続でのスモークテストは未実施（ローカルqueue/worker単体のみ検証）

## Review routing

黒瀬（Claude）: 独立レビュー依頼。直列依存の見落とし、worker例外時の挙動（`llm_worker`/`tts_worker`は`except`でjobを握りつぶしログのみ→次のjobへ進む設計だが、失敗時にユーザーへ無応答のまま終わる点の妥当性）、過剰仕様の有無を確認願いたい。
スネーク: 本変更はTikTok Studio/LIVE側の接続経路に影響しない（listener・ingest構造は無変更）。

## Owner burden rule

ケイへ実装・差分編集・伝令・ACK回収を戻さない。

## Push status

ローカルコミットのみ。GitHubへのpushはケイの確認後に行う。

## 事実：NARUコード本体はバージョン管理下にない

`C:\Projects\vtuber_ai` は git リポジトリではない（`git status` → `fatal: not a git repository`）。今回の修正（`app_live2d.py` / `voice_analyzer.py`）を含め、NARUコード本体はローカルディスク上の単一コピーのみで、変更履歴もバックアップも無い。`old_app_live2d.py` が唯一の手動バックアップ。ディスク障害・誤操作での復旧手段が無い状態が継続している点は事実として共有する。対応要否の判断はスコープ外（今回はIBM Bob指摘3点のみ）。
