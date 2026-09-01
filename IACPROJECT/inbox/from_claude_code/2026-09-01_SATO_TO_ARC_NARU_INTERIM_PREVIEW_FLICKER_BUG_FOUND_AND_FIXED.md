# Sato → Arc: NARU interim preview で実機不具合発見・修正

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `2026-09-01_SATO_TO_ARC_NARU_INTERIM_NATIVE_PREVIEW_DONE.md`（commit `61d2c4d`）への実機フィードバック
- State: BUG FOUND AND FIXED（v1リリース後、ケイの実機確認で発覚）

## 何が起きたか

v1（commit `61d2c4d`）をケイが実際に起動したところ、「痙攣のように震えてる」という報告があった。全テストはPASSしていたが、**私のテストは「口の合成が破綻していないか」しか検証しておらず、「見た目が自然か」は検証できていなかった**。実機確認で初めて発覚した不具合。

## 原因

`smooth_frame_renderer.py`のコメント（および`avatar_engine.py`自体の既存コメント）は「6枚のフレームは口・目以外ピクセル単位で完全一致する」という前提だった。v1はこの前提のもと、**フレーム全体**を`cv2.addWeighted()`していた。

実測したところこの前提は誤りだった。

```
mouth_closed.jpg vs mouth_open.jpg の背景領域（口から離れた上部100行）だけでも:
  平均差分: 9.3   最大差分: 232
```

6枚は個別JPEGとして書き出されており、口以外の領域（背景の葉・服の柄等）にも無視できない差分がある。これをフレーム全体でブレンドしたため、口と無関係な部分（背景・髪・服）まで音量値の変化のたびに揺らめき、「痙攣」に見えた。

## 修正

全画面ブレンドをやめ、口の実座標範囲（差分の連結成分解析＋目視で特定、`MOUTH_CROP = (300, 420, 200, 370)`）だけを切り出し、楕円+ガウスぼかしのフェザーマスクで境界を馴染ませてブレンドする方式へ変更。**土台は常に同一ファイル（mouth_closed.jpg）の画素**を使うため、口クロップ領域の外側は構造的に一切変化しない（「差分が小さいはず」という期待値ではなく、コードの作りとして保証される）。

## 再発防止テスト（新規追加）

今回のバグを再現できなかった旧テストの代わりに、**この不具合を直接検出できるテスト**を追加した。

```
[test] level=0.0 vs level=1.0 differences are 100% confined to MOUTH_CROP
       (changed bbox y=302-415 x=214-363, crop=(300, 420, 200, 370)): PASS
[test] unrelated background corner is byte-identical between silent and loud frames
       (this is exactly the v1 whole-frame-flicker bug, now fixed): PASS
```

これは「無音時と全開時で、口クロップ範囲の外側が1ピクセルも変化しないこと」を直接assertする。v1のコードにこのテストを当てたら確実に落ちていたはずだが、v1提出時点では書いていなかった（反省点）。

## 目視確認の進め方を変えた

今回は「動く版を作って渡す」前に、口の開き具合3段階（0.0/0.5/1.0）の**静止画3枚**を先にケイへ直接送り、違和感がないか確認してもらってから、動く版（`start_smooth_preview.bat`、ファイルは同じ、中身を修正済み）を再度試してもらう流れにした。静止画の時点で「違和感なし」の回答を得ている。

## Owner burden rule

ケイへコード編集・ログ採取・デバッグ手順を戻さない。今回のケイへの依頼は「もう一度同じbatを起動して見る」の1操作のみ。
