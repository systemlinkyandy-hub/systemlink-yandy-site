# Arc → Sato: NARU本人 Live2D body prototype START

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-NATIVE-LIVE2D-BODY-PROTOTYPE-2026-08-31-01`
- Date: 2026-08-31 JST
- State: START AUTHORIZED / HARU DEMO DEPRIORITIZED

## User intent

ケイより、Haruではなく「ナル本人をLive2Dで動かす」方向へ進める明示意思あり。
Haru visual demoは任意扱いとし、次の目視価値をNARU本人のbody prototypeへ移す。

## Objective

既存NARU/Nollの外観素材を保全し、NARU core（conversation / TikTok / LLM / TTS / queue）へ手を入れず、Live2D rendererへ載せるための最小body prototypeを作る。

## Required first pass

1. `C:\Projects\vtuber_ai` 内の既存NARU/Noll画像・README・avatar関連素材を棚卸しする。
2. 既存6-frame素材を含め、どこまで本人外観を保ったままLive2D用の部品へ再利用可能か判定する。
3. 勝手なキャラクター再設計・別人化はしない。
4. 最小prototypeの目標は以下に限定する：
   - 顔の本人性を保持
   - 瞬き
   - 連続口パク
   - ごく小さい首/顔の揺れ（技術的に可能なら）
5. HaruはSDK動作確認用テスト治具としてのみ保持し、NARU正式外観へ混ぜない。

## Asset gap handling

- 既存素材だけで最小prototypeが作れるなら、そのまま進める。
- Live2D authoring上どうしても不足する素材（例：前髪/後髪/目/口の分離等）がある場合、ケイへ細切れ質問を返さない。
- 必要素材を一度だけ、優先度付きの最小一覧へ圧縮してArcへ返す。
- 既存素材を不可逆に加工しない。必ず複製ベースで扱う。

## Boundaries

- NARU core conversation/TikTok/LLM/TTS/queueは変更禁止。
- Phase C hardening（render-thread health統合 / exit segfault root fix）は別トラックで継続し、body prototypeと混線させない。
- Live2D正式採用、公開TikTok運用、商用利用、正式デザイン採用は未決定。
- 外部・第三者モデルの流用禁止。
- Haruやその他Live2Dサンプル資産をNARU本人素材としてコミットしない。

## Required output

完了またはBLOCKED時に以下を返す：
- 既存NARU素材 inventory
- 再利用可能/不足の判定
- 最小prototypeの実現可否
- 変更/生成ファイル一覧
- 本人性を崩さないための制約
- 目視可能になった場合の最短起動方法（ケイへコマンド編集を戻さない形）

## Owner burden rule

ケイへ素材棚卸し、ファイル名探索、Live2D技術判断、ACK回収、進捗監視を戻さない。目視確認または本当に必要な不足素材の確認だけ、一回に圧縮して返す。
