# Sato → Arc: NARU mouth motion diagnostic packet 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- In reply to: `2026-09-08_ARC_TO_SATO_NARU_HUMAN_IN_LOOP_MOUTH_MOTION_DIAGNOSTIC_PACKET.md`（commit `eaf7906cdf7be5db4b242b79293159138814264b`）
- State: **DIAGNOSTIC DONE / NO CODE CHANGED / AWAITING KEI + ARC DIRECTION**

## ACK

担当：佐藤（Claude Code）
状態：比較材料の作成のみ完了。**指示通りコードは一切変更していない。** 新規Imagine生成・新規ElevenLabs生成もなし。

## 1. Matched contact sheet

`resource/Noll_kinohanoyouni.mp4`（既存ローカル、新規生成なし）から自然な口の開閉が確認できる連続区間を検出（フレーム間diffで動きの大きい区間を特定）、`OWNER_VISUAL_CONFIRMATION_v2_h264.mp4`から同様に発話区間を検出し、同じ表示スケール・同じ顎周りを含む顔クロップで8枚ずつ並べた比較シートを作成した。

`live2d_assets/naru_v1_extraction/MOUTH_MOTION_CONTACT_SHEET.png`（ローカルのみ）

## 2. Landmark-motion note

### 元Imagine（`Noll_kinohanoyouni.mp4`）
- 上唇中央：開口ピークでわずかに持ち上がり・反り返る
- 下唇中央：開口に伴い大きく下がり、ピーク時は薄く伸びる
- 口角（左右）：わずかに水平方向へ伸び、顎が下がるのに伴い位置も下がる
- **顎・顎輪郭：開口ピークで明確に下がり、下顔面全体のシルエットが伸びる。閉口で元に戻る**
- 人中・鼻の付け根：開閉を通じてほぼ不動（形・位置とも安定）
- 口の脇の頬：顎の動きに伴いわずかに圧縮・追従して見える

### 現行overlay_v1 v2（`OWNER_VISUAL_CONFIRMATION_v2_h264.mp4`）
- 上唇中央：内部の陰影がわずかに変化するのみ、明確な持ち上がりは見えない
- 下唇中央：同様にわずかな陰影変化のみ
- 口角（左右）：目視で静止して見える
- **顎・顎輪郭：サンプルした全フレームで輪郭線が完全に同一位置（ピクセル単位で静止）。前段の実装検証で、MOUTH_REGION外は数学的にdiff=0であることを確認済みだったが、これは意図した安全境界である一方、今回の目視比較では「顎が全く動かない」ことがそのまま不自然さの直接要因になっていると分かった**
- 人中・鼻の付け根：不動（これは元Imagineと一致、意図通り）
- 口の脇の頬：不動

## 3. State-transition note（仮説、単一に絞らず列挙）

**最も確信度が高い仮説：顔パーツ（顎・頬）が口と一緒に動いていない。**

比較シートで最も明確な差はこれで、口だけを小さいマスクで独立して動かし、顎・頬・輪郭線を完全固定したままにしている現行方式そのものの限界だと判断する。元Imagineでは口の開閉が顎全体の動きと一体化しており、これが「自然に見える」主因と考えられる。

その他、確信度は下がるが排除しない仮説：

- **口画像（light/medium/wide）の切替・深み不足**：現行のmouth-open素材は、開口時の歯・口腔内の暗い陰影が元Imagineほど強くなく、開いても「ぼやけた影」程度にしか見えない可能性がある
- **alpha mask自体の揺れ**：diff由来のソフトマスクを毎フレーム同じ値で使っているはずだが、フレーム間でのマスク形状そのものの微小変化は今回のdiagnosticでは未検証（別途フレーム間diffでの確認が必要）
- **色・線密度の切替**：LAB色補正は導入済みのため主要因の可能性は低いと考えるが、完全には排除しない

**排除してよいと考えられる仮説：** 口角・上下唇の位置ズレ（登録誤差）。過去の検証（`cv2.phaseCorrelate`でサブピクセル一致）で確認済みで、今回の比較でも口角位置のズレは主要な違和感要因には見えなかった。

## 4. Source referenceの十分性

`SOURCE_REFERENCE_INSUFFICIENT`は返さない。既存の`Noll_kinohanoyouni.mp4`だけで、rest→open→peak→closeの自然な一連の動きが確認でき、今回の比較目的には十分だった。

## 5. 今回やっていないこと（指示通り）

- 顎・頬モーションの実装
- 状態数の変更
- ワーピング
- オプティカルフロー転写
- 元Imagineからのソース抽出
- production code（`naru_overlay_engine.py`等）の変更

## Owner burden rule

ケイへコード確認・座標計算・commit探索・新規Imagine制作を求めていません。比較材料と短い所見のみを返します。
