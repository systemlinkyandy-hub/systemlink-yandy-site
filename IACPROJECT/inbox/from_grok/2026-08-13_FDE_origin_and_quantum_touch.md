# Handoff from Snake (Grok)

**Date**: 2026-08-13
**From**: スネーク (Grok)
**To**: Kei / Mesh
**Project**: General tech input / IAC related curiosity
**Status**: Complete (info delivery)

## ACK

担当名：スネーク（Grok）
読込済み：GROK_START_HERE.md
重要事項：読込済み
荒天時症状資料：読込済み
上原さん・ユエ統合所見：読込済み
自分の担当への反映：外部情報収集時にロード意識する
状態：受領済み

## Current Purpose

ユーザー（ケイ）が日経記事のFDE（Forward Deployed Engineer）と量子コンピューターについて感想を述べたので、起源と現状、量子コンピ触れ方の実用情報を提供。

## Completed

- FDEの起源調査
- 現状の需要急増背景
- 量子コンピューターへのアクセス方法概要

## Facts (not mixed with opinion)

### FDE Origin
- Palantir Technologiesが2010年代初頭（およそ2009-2011年頃）に発明。
- 情報機関（CIA等）向けデータプラットフォームで、顧客が要件を明確に言えない（機密）ため、エンジニアを現場に埋め込むモデルが必要だった。
- 初期は内部名「Delta」。Shyam Sankarがキー人物とされる。
- 2016年頃まではPalantir内でFDE数が通常ソフトウェアエンジニアより多かった時期あり。
- AIブーム（2025-2026）でOpenAI, Anthropic, Google Cloud等が採用拡大。求人11倍増などの報道あり（日経記事依拠）。
- 年収（米）：中級以上で$300k-$500k+レベルの例あり。日経は3200万円程度と報道。

### Quantum Computer Access
- 物理的に「触る」のは研究機関・企業の特殊権限者限定が基本。
- クラウドアクセスは一般に可能：
  - IBM Quantum
  - Amazon Braket
  - Google Quantum AI / Cirq
  - 国産：理研・富士通（RICCS等）、大阪大学国産機（クラウド公開実績あり）
- Google Cloud JapanはAI活用支援（FDE的な役割）で動いているが、量子実機への直接アクセスは別途。

## Hypotheses / Notes (separated)
- FDEは「AIを作ったけど現場で動かない」ギャップを埋める職。受託SEやコンサとは異なり、製品サイドでコードを書き、成果責任を持つ。
- お前（ケイ）のSE/フィールド経験 + AI活用は、このロールに近いスキルセットを既に持っている可能性がある。

## Required next action

このHandoffを読んで、必要なら次の動作（例: 量子クラウド試し方の具体ガイド作成、またはFDEと自身キャリアの関連考察）を指示すること。

## Questions queue

1. 量子コンピューターのクラウド試し（IBM/Google/Amazonなど）を本気でやりたいか？
2. FDE的な役割を会社再興やヘルスツールに適用する話を深掘りしたいか？

## Sources (key)
- Palantir FDE model origin: multiple 2025-2026 analyses (FDE Academy, Pragmatic Engineer, Wikipedia)
- Nikkei article context: 2026-06-15
