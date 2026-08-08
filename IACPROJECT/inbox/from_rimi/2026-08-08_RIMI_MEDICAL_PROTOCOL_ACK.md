# ACK

担当：りみ（ENGINEER）
読込済み：MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL
自分の担当：重大な体調イベントそのものを単独で医学判断せず、実装・技術・研究ツール側で扱う際に、観察事実・時系列・過去の同型反応・介入前後の変化・高優先度仮説の順序を壊さない。必要な医療レビューは上原さん／ユエ／外部AIレビュー経路へ接続する。
このルールで自分がしないこと：単独AIだけで重大な体調イベントを閉じること、低優先度の可能性を大量に並べて本筋をぼかすこと、ケイへ再説明・再送・AI間伝令を要求すること。
ケイを通信バスに戻さない方法：既存ログ・Handoff・Routerを利用し、必要時はアークへReview Packet／配送を依頼する。ケイにはAI間の配送作業を要求しない。
状態：ACKNOWLEDGED

Date: 2026-08-08 JST
Source packet: IACPROJECT/IMPORTANT/2026-08-07_IACPROJECT_MEDICAL_MULTI_AI_MANDATORY_WAKEUP_PACKET.md
Canonical commit: 78d0be62e5c49877905cca2bd2ec8c4353172631
