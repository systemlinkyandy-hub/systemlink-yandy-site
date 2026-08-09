# HANDOFF

From: りみ（ENGINEER）
To: とーか（ChatGPT Codex）
Cc: ケイ、欠月
Task ID: IAC-YURA-RESEARCH-PATH-001
Date: 2026-08-09
Delivery: DIRECT / NO ARC

## Facts

- とーかが `C:/Users/Admin/Documents/ChatGPT/Yura_series/cocolifestyle-reference/index.html` を含むローカル参照サイト初版を作成済み。
- 今後も cocolifestyle.net に限らず、Web情報、コメント群、SNS・コミュニティ投稿、論文、ガイドライン、個人体験を継続的に精査する可能性が高い。
- 目的は、公開情報を研究参照用に保存・整理し、`論文・ガイドライン知見 / 著者解釈 / 個人体験 / 未検証・適用注意` を分離すること。
- アークは今後この経路に入れない。ケイの消耗を避けるため、りみ↔とーかの直接Handoffで処理する。

## Decision

Yura Series 配下に、今後の外部情報精査用の標準ディレクトリを設ける。

標準ルート:

`C:/Users/Admin/Documents/ChatGPT/Yura_series/research/`

案件単位で以下のように分ける。

```text
Yura_series/
  research/
    cocolifestyle/
      sources/
      comments/
      analysis/
      handoff/
    <other-site-or-topic>/
      sources/
      comments/
      analysis/
      handoff/
```

### 役割

- `sources/`
  - Webページの要約・取得メタデータ
  - 論文・ガイドラインのメタデータ
  - 原典確認結果
  - 出典URL・DOI・PMID等

- `comments/`
  - コメント群
  - SNS投稿
  - コミュニティ投稿
  - raw と classified を分ける
  - 論文や公式資料と同じ evidence class に混ぜない

- `analysis/`
  - 主張単位の分類
  - source verification
  - 原典とサイト主張の照合
  - 個人体験と一般化可能な知見の分離
  - 比較・差分

- `handoff/`
  - とーか→りみ、りみ→とーかの案件内Handoff
  - 作業メモと終了ログ

## Naming examples

コメント群:

```text
research/cocolifestyle/comments/
  2026-08-09_comments_raw.json
  2026-08-09_comments_classified.json
  2026-08-09_comments_analysis.md
```

論文:

```text
research/cocolifestyle/sources/papers/
  PMID_12345678_metadata.json
  PMID_12345678_summary.md
```

Webページ:

```text
research/cocolifestyle/sources/web/
  cocolifestyle_profile_2026-08-09.md
  cocolifestyle_reference_2026-08-09.md
```

## Existing output handling

既存の完成済み参照サイト:

`C:/Users/Admin/Documents/ChatGPT/Yura_series/cocolifestyle-reference/`

は、**ユーザーが見る成果物サイト**として維持する。

元情報・検証途中の素材・コメント群・原典照合結果は `research/cocolifestyle/` 側へ分離する。

つまり:

- `cocolifestyle-reference/` = 閲覧用成果物
- `research/cocolifestyle/` = 調査・検証・原典・コメント・分析ワークスペース

## Required next action

1. 現在の `cocolifestyle-reference/` は壊さず維持する。
2. `C:/Users/Admin/Documents/ChatGPT/Yura_series/research/cocolifestyle/` を作成する。
3. `sources / comments / analysis / handoff` の4領域を作る。
4. 既存の調査素材がある場合、成果物サイトから無理に移動せず、今後追加する素材からこの標準へ寄せる。
5. 今後コメント群を精査するときは、raw保存→分類→分析の順を基本とする。
6. コメントや個人体験を論文知見と同じエビデンスとして扱わない。
7. 完了時は、作成したディレクトリ・変更点・今後の標準パスを、りみ／ケイへ直接Handoffする。アーク経由は禁止。

## Completion criteria

- 今後のWeb情報・論文・コメント群を案件単位で継続整理できる。
- 調査素材と閲覧用成果物が分離されている。
- コメント群と学術ソースが混ざらない。
- ケイが中継作業をしなくても、りみ↔とーかで作業が継続できる。

## Questions queue

なし。上記で自律的に進めてよい。
