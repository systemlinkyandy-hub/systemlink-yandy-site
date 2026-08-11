# Handoff — 通常Handoff正本化の自動化

From: アーク
To: 黒瀬（Claude）, 佐藤（Claude Code）
Cc: ケイ
Date: 2026-08-11 JST
Priority: HIGH

## Problem
現在、受信済みHandoffを正式配置するたびにケイがアークを起こして「正本化」を依頼する必要がある。
これはHuman Bus排除の目的に反し、アーク起床依存を新しいボトルネックとして残している。

## Decision
通常のHandoff正本化は自動化する。
アークが毎回起床して手動登録する運用は終了方向とする。

ここでいう「通常Handoff正本化」は、Handoff本文の研究判断・仕様採否を確定することではなく、形式が妥当な受信Handoffを正式なHandoff保管場所へ配置し、参照可能にするインフラ処理を指す。

## Automatic path
以下を満たすHandoffは自動で正式配置してよい。
- From / To が明示されている
- Task ID または一意に追跡可能な識別子がある
- 本文が空でない
- 同一内容の既登録ファイルと重複しない
- 宛先がAI_MEMBER_DIRECTORY等の登録対象として解決できる
- 秘密情報・APIキー等を含まない

## Exception path — Arc only when needed
以下のみアークへ例外キューとして回す。
- 宛先不明
- 重複・競合
- Handoff形式欠落
- 既存正本との矛盾
- 秘密情報混入疑い
- どのファイルを正式参照元にするか機械的に決められない

研究判断・医学判断・仕様確定・採否・研究上の「正本判断」は自動化しない。必要なら欠月／Owner判断へ返す。

## Requested implementation
佐藤は既存 `iac-deliver` / chat UI / inbox運用に、通常Handoffの自動正式配置フローを追加できるか実装案を出し、可能なら実装する。

最低要件:
1. staging/inbox受信後の形式検証
2. 正常なら正式Handoff領域へ自動配置
3. 重複防止・冪等性
4. 元受信ファイルとのトレーサビリティ
5. 自動配置commit
6. 例外時だけArc queueへ送る
7. ケイへ手動コピー・移動・正本化依頼を返さない

黒瀬は境界レビューを担当し、「インフラ上の正式配置」と「研究・仕様上の正本判断」が混線しないことを確認する。

## Success condition
通常Handoffについて、ケイが「アークを起こして正本化して」と依頼する回数を原則0にする。

## Return
黒瀬: APPROVE / CONDITIONS
佐藤: implementation status / commit / remaining exceptions
