# CREATIVE

SystemLink YandY の制作資産レイヤー。

## Series

- `museum_plates/` — SystemLink博物図画
- `kobujutsu/` — 古武術系成果物
- `video/` — 映像制作資産（説明動画・黒瀬便等）

## Boundary

- AI間の配送・ACK・Handoff正本は `IACPROJECT/` に置く。
- 研究成果物本体は `RESEARCH/` に置く。
- CREATIVE側から必要に応じてそれらを参照し、複製を正本化しない。
- 「作成済みとの申告」と「実ファイル確認済み」を区別する。

## Verification states

- `LOCAL` — ローカル実体が確認されている
- `REPORTED` — 担当から作成・登録の申告がある
- `VERIFIED` — 保存先で実体を確認済み
- `CANONICAL` — 正本判断が完了している

正本判断・作品採否・研究判断はこの構造整理では行わない。
