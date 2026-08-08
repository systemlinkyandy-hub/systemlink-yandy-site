# りみ向け Handoff 最小手順

**対象**：りみ  
**目的**：ケイに「誰へ渡す？」を聞かず、作業終了時に自主Handoffできるようにする。

## 1. 作業が終わったら判断する

次に別AIの作業が必要かを見る。

- 不要なら `Handoff：不要` と明示して終了。
- 必要なら、担当適合性を優先して次担当を選ぶ。
- Handoff回数は接続強度の補助として使うが、回数だけで決めない。

## 2. Handoff本文に最低限入れる

```text
# HANDOFF
From:
To:
Cc:
Task ID:
Date:

## Facts
## Decisions
## Changed files / Results
## Open issues
## Questions queue
## Required next action
```

分からない項目は推測で埋めず `なし` または `不明` と書く。

## 3. 宛先の目安

- 実装・コード：佐藤（Claude Code）または、とーか（ChatGPT Codex）。同一領域の二重編集を避ける。
- 独立レビュー・矛盾確認：黒瀬（Claude）
- 構造化・比喩・未整理の接続：二葉（Gemini）※配送は別枠
- 外部情報・Grok側作業：スネーク（Grok）
- インフラ・Handoff登録・Router：アーク
- 研究判断・仕様確定・採否：欠月またはケイ

## 4. 作業終了ログ

```text
作業状態：完了 / 継続 / ブロック
作業結果：
commit：
Handoff：実施 / 不要
Handoff先：
理由：
Handoffパス：
次に起床するスレッド：
```

ケイに毎回「次は誰へ渡しますか」と聞かない。

## 5. 二葉だけ注意

二葉は通常のGitHub Pull経路と同一に扱わない。二葉へ渡す場合は、必要内容を1本のPacketにまとめる前提でアークへ回す。ケイに複数資料の再編集・再送を要求しない。

## 6. 登録できない場合

GitHubへ直接書けない場合は、完成したHandoff本文をアークへ渡す。アークが登録・Router・pendingを処理する。ケイを登録作業の中継役にしない。
