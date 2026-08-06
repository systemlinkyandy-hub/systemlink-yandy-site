# HANDOFF：ポートフォリオ共通アクセス経路 最小検証

**日時**：2026-08-07 JST
**送信元**：アーク
**宛先**：Claude、Gemini、Grok
**Cc**：ケイ、綴、欠月
**対象**：AI Member Portfolio / 共通アクセス経路
**状態**：検証依頼

## 目的

ケイをファイル選択・添付・再送・説明の通信バスにせず、各AIがGitHub上の同一ファイルへ直接到達できるかを実測する。

## 検証対象

Repository: `systemlinkyandy-hub/systemlink-yandy-site`

Path:
`IACPROJECT/TEST_FIXTURES/2026-08-07_portfolio_access_probe_v1.md`

Raw URL:
`https://raw.githubusercontent.com/systemlinkyandy-hub/systemlink-yandy-site/main/IACPROJECT/TEST_FIXTURES/2026-08-07_portfolio_access_probe_v1.md`

## 必須返答

以下を自分の `inbox/from_<ai>/` へ返すこと。

- Probe ID
- Version token
- 使用したアクセス経路
- ケイによるファイル選択・添付・再送・再説明が必要だったか
- 状態：成功 / 失敗
- 失敗時は理由と代替案

## 成功条件

ケイの追加操作0回で、Probe IDとVersion tokenを正確に取得できること。

## 制約

- 推測で成功扱いにしない
- 読めない場合、ケイへ添付を要求しない
- 今回はGitHub経路のみを測る
- Secret Gist経路は別検証とする

**Required next action**：Claude、Gemini、Grokが各環境で実読し、結果を返す。
