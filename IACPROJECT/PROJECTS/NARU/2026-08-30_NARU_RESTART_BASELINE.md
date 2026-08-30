# NARU Restart Baseline

- Project: TikTok AI Liver / NARU
- Date: 2026-08-30 JST
- Owner: ケイ
- Coordinator / Router: アーク
- State: RESTART AUTHORIZED / LOCAL CODE FOUND

## 1. 結論

TikTok AI搭載ライバー「ナル」を再稼働する。
IBM Bobで行った一次査定の成果は、BobをIACProjectへ直接組み込む材料ではなく、ナルの実装改善へ吸収する。

## 2. 既知のベースライン

### IBM Bob線
- Bobは既存IACProjectを置換する目的ではなく、同一小課題で比較し「良いところを吸収する」評価線として開始した。
- 2026-08-26時点の一次査定は PASS。
- 主要な技術問題として以下が残っている。
  1. 直列ブロッキング
  2. 架空／実在確認できないモデル名の混入
  3. TTS遅延

### 旧ナル線
- 基本パイプラインは `コメント入力 -> LLM応答 -> ElevenLabs音声`。
- ElevenLabs利用実績あり。
- 会話面では、同種入力へ観察系応答が連続する単調さが既知課題。
- 改善案として `observe / accept / minimal` 等の応答モード分岐が以前提示されている。

## 3. 2026-08-30 Local Discovery

デスクトップPC上で旧ナル実装の実体を確認した。

- local path: `C:\Projects\vtuber_ai`
- visible files / directories:
  - `.venv/`
  - `__pycache__/`
  - `avatar_frames/`
  - `history/`
  - `Old/`
  - `output/`
  - `resource/`
  - `.env`
  - `app.py`
  - `app_live2d.py`
  - `avatar_engine.py`
  - `output.mp3`
  - `output.wav`
  - `prompts.py`
  - `pronunciation_manager.py`
  - `README_LIVE2D.md`
  - `start_live2d.bat`
  - `subtitle_scroller.py`
  - `tts_dict.py`
  - `voice_analyzer.py`
  - `vtuber-ai.html`

### Discovery decision

コード所在探索は完了。
次は `README_LIVE2D.md` の起動手順確認を先に行い、`.env` を不用意に画面共有しない。
`start_live2d.bat` は内容／手順確認前に実行しない。

## 4. 今回の再稼働範囲

今回の完了条件は「ナルが再びライブ応答できること」。

必須:
1. 既存ナル実装の所在を特定する。 **DONE: `C:\Projects\vtuber_ai`**
2. 現在の環境で起動可能にする。
3. 架空モデル名／無効なモデル設定を排除し、実在する設定値へ置換する。
4. コメント受信、LLM生成、TTS再生を単純直列で待たせない構造へ修正する。
5. TTS待ち時間を計測し、ボトルネックを分離する。
6. 連続コメント時に応答キューが破綻しないことを確認する。
7. 旧ナルの応答単調化を最低限抑える。
8. TikTok側へ映像・音声を流せるところまでスモークテストする。

今回は後回し:
- ギフト収益化の最適化
- 長期自律配信
- 大規模マルチエージェント化
- IACProject本体へのBob直接統合

## 5. 実装上の優先順位

### P0: 再起動
- code location: **FOUND `C:\Projects\vtuber_ai`**
- dependency / env確認
- API keyはリポジトリへ保存しない
- 実モデル名確認
- 最小1往復の応答

### P1: 直列ブロッキング解消
最低限、以下を分離する。
- comment ingest
- response generation
- TTS generation
- audio playback/output

キュー／非同期処理を用い、TTS完了待ちでコメント受信自体を止めない。

### P1: TTS遅延
以下を別々に計測する。
- comment received -> LLM request
- LLM request -> text ready
- text ready -> TTS request
- TTS request -> first audio ready
- first audio ready -> playback start

「遅い」を一括評価せず、区間計測値を残す。

### P1: モデル設定健全化
- コード中にモデル名を散在させない。
- config / env / single source of truth に集約する。
- 実在確認できないモデル名はfallbackせずエラーとして表面化させる。

### P2: 会話の単調化抑制
応答モードを最低限持つ。
- observe
- accept
- minimal
必要以上に人格設計を増やさず、同一パターン連発だけを止める。

## 6. 役割

- アーク: Router、状態管理、Handoff、ACK追跡。実装はしない。
- 佐藤（Claude Code）: 既存コード探索、復旧実装、非同期化、計測、テスト。
- 黒瀬（Claude）: 復旧後の独立レビュー。直列依存、失敗時挙動、過剰仕様を確認。
- スネーク（Grok）: TikTok Studio / LIVE側の現行接続条件・UI経路確認。実装仕様の最終決定はしない。

## 7. 次のRequired Next Action

`README_LIVE2D.md` を確認して、起動手順・必要プロセス・TikTok/Live2D連携前提を特定する。

その後、佐藤は以下を返す。

1. 現在の起動方法
2. 依存関係
3. LLM provider / model設定箇所
4. ElevenLabs設定箇所
5. コメント入力経路
6. 音声出力経路
7. 直列ブロッキング箇所
8. 最小修正案

コード所在を確認する前に全面書き直しを開始しない。

## 8. Done Definition

最低1回、実コメントまたは同等のテスト入力に対し、

`comment received -> LLM text -> TTS -> audio output`

が通り、その間も次コメント受信ループが停止しないこと。

その後、黒瀬レビューを通して再稼働完了とする。
