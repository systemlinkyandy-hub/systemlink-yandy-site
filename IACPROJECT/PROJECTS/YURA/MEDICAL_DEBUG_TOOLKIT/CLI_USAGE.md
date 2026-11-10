# build_debug_packet.py

標準ライブラリだけで動く暫定CLI。

## 入力

- debug event JSONL: `debug_event.schema.json` に沿ったイベント
- claim ledger CSV: `claim_ledger.csv`

## 基本実行

```bash
python build_debug_packet.py \
  --events sample_events.jsonl \
  --claims claim_ledger.csv \
  --output out/packet.md
```

期間指定:

```bash
python build_debug_packet.py \
  --events events.jsonl \
  --claims claim_ledger.csv \
  --from 2026-11-01T00:00:00+09:00 \
  --to 2026-11-11T23:59:59+09:00 \
  --output out/packet.md
```

ストレッサータグ指定:

```bash
python build_debug_packet.py \
  --events events.jsonl \
  --tag explanatory_labor \
  --output out/explanatory_labor.md
```

外部共有向け:

```bash
python build_debug_packet.py \
  --events events.jsonl \
  --claims claim_ledger.csv \
  --public \
  --output out/public_packet.md
```

`--public` は source_ref を出力しない。完全匿名化を保証するものではないため、
共有前に `redaction_checklist.md` を必ず確認する。

## 実装境界

このCLIは診断・治療・因果推定を行わない。
入力された Observation / Inference / Claim を分離したままMarkdownへ整形するだけ。

将来は RCW の ImportedEvent / HealthEnvLogger / Cortisol HP importer の出力を
変換アダプタで接続する。
