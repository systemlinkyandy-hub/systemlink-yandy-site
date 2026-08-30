# Handoff: State Tracker review parser — 黒瀬の見出し型判定を拾えるよう修正

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, ユエ
- Date: 2026-08-30 JST
- Task ID: HANDOFF-STATE-TRACKING-2026-08-30-01
- Priority: HIGH / PILOT FIX
- State: IMPLEMENTATION REQUESTED

## Context

黒瀬から、NARUレビューとHandoff State Trackerレビューはいずれも実務上は完了しているが、黒瀬本人のオリジナルMarkdownがまだGitHubへ登録されていないため、現行機械判定ではREVIEWEDにならないとの整理が入った。

これは一次証拠未登録のため当然であり、現行trackerの誤りではない。

一方で別の既知問題がある。黒瀬の実際の判定文は、現行実装が要求する `判定:` / `Verdict:` の同一行ラベル形式ではなく、Markdown見出しとして

- `## 判定`
- その直後の本文または次行に `APPROVE` / `APPROVE WITH CONDITIONS` / `HOLD`

のような形式を使うことがある。

したがって、黒瀬一次レビューMarkdownがGitHubへ登録された後でも、現行regexではREVIEWEDを拾えない可能性が高い。

## Required change

`tools/iac-handoff-state.ps1` の REVIEWED/CLOSED 判定を、false positiveを再導入せずに以下へ拡張する。

1. 既存の同一行形式は維持
   - `判定: APPROVE`
   - `Verdict: HOLD`
2. Markdown見出し形式を追加
   - `## 判定`
   - `## Verdict`
   - 見出し直後の限定範囲（例: 次の非空行1〜3行）だけをreview verdict候補として読む
3. verdict tokenは限定集合のみ
   - `APPROVE`
   - `APPROVE WITH CONDITIONS`
   - `HOLD`
   - 必要なら既存運用で明示された等価語のみ
4. source proposal等の一般本文にある「判定」「承認」語では絶対にREVIEWEDにしない
5. reviewerはsource sender / task recipient以外の第三者であることを維持
6. CLOSEDは従来どおり必要evidenceのAND条件を維持し、review parser拡張だけで単独CLOSEDしない

## Test requirements

実API不要。合成fixtureで最低限以下をPASSさせる。

- `## 判定` + 次行 `APPROVE` => REVIEWED=YES
- `## 判定` + 次行 `APPROVE WITH CONDITIONS` => REVIEWED=YES, CLOSEDは条件次第
- 一般本文の「機械判定する」 => REVIEWED=NO
- 見出しから離れた本文中の `APPROVE` => REVIEWED=NO
- source/recipient本人による自己判定 => REVIEWED=NO
- 現在のfalse CLOSED再発テスト => PASS

## Evidence handling

黒瀬本人のNARU / State TrackerレビューMarkdownはケイが別途GitHubへ登録予定。登録前にそれらを機械上REVIEWED扱いしないこと。

登録後、同じtask_idに紐づく一次review artifactとしてscannerが検出できるか再Scanする。

## Owner burden rule

ケイへregex修正、テスト、再Scan、ACK照合を戻さない。
