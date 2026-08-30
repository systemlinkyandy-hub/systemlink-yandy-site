# Sato → Arc/Kurose: NARU 実TikTok smoke test 実施報告

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, スネーク（Grok）
- Date: 2026-08-30 23時台 JST
- Task 系列: NARU IBM Bob 指摘3点修正 → 黒瀬条件修正 → 黒瀬APPROVE → 実TikTok smoke test
- 関連: `IACPROJECT/inbox/from_claude_code/2026-08-30_SATO_TO_ARC_NARU_KUROSE_APPROVE_RELAYED.md`
- State: REAL SMOKE TEST DONE

## 事実／未確認の区別（先に明示）

**事実（佐藤が直接確認）**：本Handoffの内容は、テスト実施中〜直後にケイからチャット経由で報告された内容に基づく。佐藤はテスト実行中のターミナルログ・実際の音声・配信画面をリアルタイムで見ていない（ローカルPCでケイが直接操作したため）。ログファイルとしての実体（`[LATENCY]`出力等）は今回GitHubへ提出していない。

**未確認**：API実コストの正確な金額。ケイから共有された残高スクリーンショットは、文脈上アーク（ChatGPT環境）側のクレジット残高に見えるため、vtuber_ai自体のOpenAI/ElevenLabs利用コストと断定していない。

## 実施内容

- 配信ソフト：TikTok LIVE Studio（OBSではなくLIVE Studio自体でウィンドウキャプチャ＋配信）
- 手順：`start_live2d.bat`起動（STANDBY）→ LIVE Studioで「Noll Live」ウィンドウキャプチャ→タイトル設定→Go Live→コンソールで`C/`（CHATモード開始）→ケイ自身のコメントで反応確認→`S/`でSTANDBYへ復帰→配信終了
- 実施時間：23時頃から約10〜15分（ケイ申告）
- コメント：ケイ本人が自分のコメントで動作確認（実運用の視聴者コメントではなく制御されたテスト入力）

## 結果（ケイ報告ベース）

- 「会話自体は悪くなかった」= LLM応答・アバター描画・口パクは動作した
- STANDBYへの復帰も正常に実施された
- ローカル録画（Windows Game Bar、`Noll Live 2026-08-30 22-58-35.mp4`）は音声トラックが実質無音（佐藤が`ffprobe`/`ffmpeg volumedetect`で直接検証：mean/max volume ともに -91dB）

## 見つかった問題（NARUのコード品質とは別枠）

録画に声が乗らなかった原因を特定した。`voice_analyzer.py`の`_play_audio()`はWindows環境で`os.startfile()`によりOS既定の別プロセス（メディアプレイヤー）を起動して再生する設計。Windows Game Barのアプリ単位録画は「そのアプリ自身が出した音」しか拾わない仕様のため、別プロセスが鳴らした音は一切録画に乗らない。

**これはNARU本体の動作不良ではない**（実際にTikTok側で視聴者に音が届いていたかどうかは、LIVE Studio自体のデスクトップ音声ミキシングに依存するため、恐らく問題なし。ローカル録画だけの問題）。

対応方針（ケイの判断）：
- 今回は次回対応で保留（`次回リベンジのときでいい`とのケイ判断）
- 短期回避策：次回はGame BarでなくOBSの「デスクトップ音声」ソースで録画する
- 恒久対応（要判断）：`_play_audio()`を`os.startfile`依存からPython内蔵の音声再生（要ライブラリ選定）へ変更し、口パクタイミングとの整合を再テストする。今回は着手していない。

## Done Definition との対応

`IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_NARU_RESTART_IMPLEMENTATION.md`の完了条件（`comment received -> LLM text -> TTS -> audio output`が実コメントで1往復以上通り、その間も次コメント受信が停止しない）は、今回の実配信でケイ自身のコメントに対して満たされたと報告されている。ただし佐藤が生ログで直接検証した事実ではなく、ケイの報告に基づく（上記「事実／未確認」参照）。厳密なログ提出が必要な場合は次回テスト時に対応する。

## Next issues（据え置き）

- ローカル録画の音声欠落（上記、対応は次回）
- `llm_queue`/`tts_queue`無制限、`_job_stage_log`失敗job微小リーク、`READ_COMMENTS_ALOUD=True`時のblocking再発、discussion/AUTO/idle非同期化、`vtuber_ai`全体のgit管理化 — いずれも既存の据え置き一覧のまま変更なし

## Owner burden rule

ケイへ実装・差分編集・伝令・ACK回収を戻さない。
