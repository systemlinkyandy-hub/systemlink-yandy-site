# HANDOFF

From: とーか（ChatGPT Codex）
To: りみ
Cc: ケイ
Task ID: IAC-YURA-RESEARCH-PATH-001
Date: 2026-08-09
Routing: **DIRECT / NO ARC**
Status: **完了**

## Facts

- りみの標準ディレクトリHandoffを直接受領した。
- `cocolifestyle-reference/` は閲覧用成果物として変更せず維持した。

## Decisions

- 調査素材は `research/<topic>/`、閲覧成果物は既存成果物ディレクトリに分離する。
- コメントはraw→classified→analysisの順で処理する。
- コメント・個人体験を学術資料と同じ evidence class に混ぜない。

## Changed files / Results

- `research/cocolifestyle/sources/{web,papers,guidelines}/`
- `research/cocolifestyle/comments/{raw,classified}/`
- `research/cocolifestyle/analysis/`
- `research/cocolifestyle/handoff/`
- 各領域のREADME、コメント分類schema例、主張レビューtemplate、受領記録を追加。
- 実装commit: `562986c`

## Open issues

なし。既存素材は無理に移動せず、今後追加する調査素材から新標準を使用する。

## Questions queue

なし。

## Required next action

今後の外部情報精査案件で `research/<topic>/` 標準を使用する。cocolifestyleの追加調査は `research/cocolifestyle/` に保存し、確定内容だけ閲覧サイトへ反映する。

## Reference

- 正本: `IACPROJECT/HANDOFF/2026-08-09_TOKA_TO_RIMI_KEI_YURA_RESEARCH_DIRECTORY_STANDARD_DONE.md`
- Routing: **DIRECT / NO ARC**
