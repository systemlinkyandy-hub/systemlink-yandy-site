# Sato → Arc: NARU interim preview デモの口パク速度修正

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `2026-09-01_SATO_TO_ARC_NARU_INTERIM_PREVIEW_FLICKER_BUG_FOUND_AND_FIXED.md`（commit `499df33`）への続報
- State: DONE（commit `185d3d3`）

## ACK

担当：佐藤（Claude Code）
新規実装：行った
状態：受領済み・実装済み

## 何が起きたか

チラつきバグ修正（`499df33`）後、ケイが再度デモを起動して確認したところ、「口パクが速すぎる」という報告があった。

## 原因

これはレンダラー本体（`smooth_frame_renderer.py`）の不具合ではない。`demo_smooth_preview.py`が使う**合成ダミー波形**（実音声の代わりに口パクを動かすためだけの疑似波形）の周波数設定が速すぎた。

```python
# 修正前
0.55 + 0.35 * math.sin(t * 3.3) * math.sin(t * 0.7)   # 速い成分の周期 約1.9秒
```

実音声を伴わずにこの波形単体を見ると、速さの基準がない分、余計に不自然・機械的に見える。

## 修正

`demo_smooth_preview.py`のみ変更（`smooth_frame_renderer.py`のブレンド・クロップ機構は無変更）。

- 速い成分の周波数を約1/3へ（3.3 → 1.1 rad/s、周期 約1.9秒 → 約5.7秒）
- ゆっくりした「文の抑揚」に相当する遅い波（0.45 rad/s）を掛け合わせ、単調な機械的往復を避けた
- 発話区間の途中に短い間（1.2秒）を挟み、切れ目なく喋り続けないようにした

## 補足（重要）

本番運用時（実TikTokコメント→LLM→TTS音声）では、口パクは**実際の音声波形の音量値**で駆動される（`voice_analyzer.py`の既存経路、今回一切変更していない）。つまり今回のペース調整はあくまで**デモ専用の疑似波形の速さ**の話であり、実際の発話時の口パク速度は元々TTS音声のリズムに追従する設計のまま。

## 検証

既存の回帰テスト（`test_naru_smooth_preview.py`、フリッカー修正時に追加した「口クロップ範囲外は変化しない」assertion含む）を再実行し、全PASSを確認済み。

## Owner burden rule

ケイへコード編集・ログ採取を戻さない。
