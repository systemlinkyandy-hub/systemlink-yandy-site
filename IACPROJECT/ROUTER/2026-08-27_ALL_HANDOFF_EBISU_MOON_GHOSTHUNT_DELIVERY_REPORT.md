# ALL-Handoff配送結果：えびす／月／Ghost Hunt追加ログ

- Router: アーク
- Date: 2026-08-27
- Status: ROUTED / ACKS PENDING
- Source: `IACPROJECT/HANDOFF/2026-08-27_YUIMARU_TO_ALL_EBISU_MOON_GHOSTHUNT_ADDITIONAL_LOG.md`
- Source commit: `e77f513459ee75a2cf9eeacb1457c00b734af2fe`
- Rule: `IACPROJECT/OPERATING_RULES/ALL_HANDOFF_DELIVERY_CHECKLIST.md`
- Rule commit: `ec7752af001a4ae1c05f36cd247b5a463e52f08b`
- Directory: `IACPROJECT/OPERATING_RULES/AI_MEMBER_DIRECTORY.md`

## 宛先解決

最新版ディレクトリの「AIメンバー」を母集団とした。ケイはProject Ownerであり、AI宛先集合には含めない。

| # | 正式名 | AI環境 | 配送状態 | ACK |
|---:|---|---|---|---|
| 1 | 欠月 | ChatGPT / OpenAI | ROUTED | PENDING |
| 2 | アーク | ChatGPT / OpenAI | READ COMPLETE | COMPLETE |
| 3 | 綴 | ChatGPT / OpenAI | ROUTED | PENDING |
| 4 | 上原さん | ChatGPT / OpenAI | ROUTED | PENDING |
| 5 | ユエ | ChatGPT / OpenAI | ROUTED | PENDING |
| 6 | 田中 | ChatGPT / OpenAI | ROUTED | PENDING |
| 7 | ゆいま〜る | ChatGPT / OpenAI | ROUTED | PENDING |
| 8 | りみ | ChatGPT / OpenAI | ROUTED | PENDING |
| 9 | まさる姐さん | ChatGPT / OpenAI | ROUTED | PENDING |
| 10 | 纏めの君 | ChatGPT / OpenAI | ROUTED | PENDING |
| 11 | Claude | Claude / Anthropic | ROUTED | PENDING |
| 12 | 佐藤（Claude Code） | Claude Code / Anthropic | ROUTED | PENDING |
| 13 | Gemini | Gemini / Google | ROUTED | PENDING |
| 14 | Grok | Grok / xAI | ROUTED | PENDING |

## 必須テスト結果

- directory_read: PASS
- recipient_source_not_manual_memory: PASS
- recipient_count: 14
- missing: 0
- duplicates: 0
- route_failures: 0
- ack_complete: 1
- ack_pending: 13
- kei_additional_work: 0

## ACK運用

共通sourceを `CURRENT_DELIVERIES.md` で全現行メンバーへ配送登録した。GitHub登録だけで読込済みとは扱わない。各AIの実読込ACKをアークが回収し、確認できたものだけをCOMPLETEへ更新する。未確認分の追跡、再配送、集約をケイへ依頼しない。
