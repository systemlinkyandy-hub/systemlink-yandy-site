#!/usr/bin/env python3
"""Build a Markdown Medical Debug Packet from Yura debug events and claim ledger.

Stdlib-only. Intended as a portable baseline before Yura/RCW integration.
Never infers medical truth; it formats supplied observations/claims.
"""
from __future__ import annotations

import argparse
import csv
import json
from datetime import datetime
from pathlib import Path
from typing import Any, Iterable


def parse_dt(value: str | None) -> datetime | None:
    if not value:
        return None
    value = value.strip()
    if not value:
        return None
    if value.endswith("Z"):
        value = value[:-1] + "+00:00"
    try:
        return datetime.fromisoformat(value)
    except ValueError:
        return None


def load_events(path: Path) -> list[dict[str, Any]]:
    events: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as fh:
        for lineno, line in enumerate(fh, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"{path}:{lineno}: invalid JSON: {exc}") from exc
            if not isinstance(obj, dict):
                raise ValueError(f"{path}:{lineno}: event must be a JSON object")
            events.append(obj)
    return events


def load_claims(path: Path | None) -> list[dict[str, str]]:
    if path is None:
        return []
    with path.open("r", encoding="utf-8-sig", newline="") as fh:
        return list(csv.DictReader(fh))


def event_dt(event: dict[str, Any]) -> datetime | None:
    return parse_dt(event.get("occurred_at")) or parse_dt(event.get("recorded_at"))


def in_range(event: dict[str, Any], start: datetime | None, end: datetime | None) -> bool:
    dt = event_dt(event)
    if dt is None:
        return start is None and end is None
    if start is not None and dt < start:
        return False
    if end is not None and dt > end:
        return False
    return True


def has_tag(event: dict[str, Any], tag: str | None) -> bool:
    if not tag:
        return True
    tags = event.get("stressor_tags") or []
    return isinstance(tags, list) and tag in tags


def esc(value: Any) -> str:
    if value is None:
        return ""
    return str(value).replace("\n", " ").replace("|", r"\|")


def event_rows(events: Iterable[dict[str, Any]], *, public: bool) -> str:
    lines = [
        "| time | layer | type | summary | source | verification |",
        "|---|---|---|---|---|---|",
    ]
    for e in events:
        time = e.get("occurred_at") or e.get("recorded_at") or ""
        source = "" if public else (e.get("source_ref") or e.get("source_type") or "")
        lines.append(
            f"| {esc(time)} | {esc(e.get('layer'))} | {esc(e.get('event_type'))} | "
            f"{esc(e.get('summary'))} | {esc(source)} | {esc(e.get('verification_status'))} |"
        )
    if len(lines) == 2:
        lines.append("| | | | （該当イベントなし） | | |")
    return "\n".join(lines)


def claim_rows(claims: Iterable[dict[str, str]], *, public: bool) -> str:
    lines = [
        "| claim_id | claim | type | verification | confidence | source |",
        "|---|---|---|---|---|---|",
    ]
    count = 0
    for c in claims:
        if c.get("claim_id", "").startswith("EXAMPLE-"):
            continue
        count += 1
        source = "" if public else c.get("source_ref", "")
        lines.append(
            f"| {esc(c.get('claim_id'))} | {esc(c.get('claim_text'))} | "
            f"{esc(c.get('claim_type'))} | {esc(c.get('verification_status'))} | "
            f"{esc(c.get('confidence'))} | {esc(source)} |"
        )
    if count == 0:
        lines.append("| | （登録済みclaimなし） | | | | |")
    return "\n".join(lines)


def build_packet(
    events: list[dict[str, Any]],
    claims: list[dict[str, str]],
    *,
    title: str,
    public: bool,
) -> str:
    events = sorted(events, key=lambda e: event_dt(e) or datetime.max)
    observed = [e for e in events if e.get("layer") in {"raw", "observation"}]
    inferred = [e for e in events if e.get("layer") in {"derived", "inference"}]
    interventions = [e for e in events if e.get("intervention")]
    responses = [e for e in events if e.get("response")]

    parts = [
        f"# {title}",
        "",
        "> 自動生成された整理用パケット。診断・治療判断を自動確定しない。",
        "",
        "## 1. Observed / Raw timeline",
        event_rows(observed, public=public),
        "",
        "## 2. Interventions",
    ]
    if interventions:
        parts.extend(
            f"- {esc(e.get('occurred_at') or e.get('recorded_at'))}: "
            f"{esc(e.get('intervention'))} — {esc(e.get('summary'))}"
            for e in interventions
        )
    else:
        parts.append("- （記録なし）")

    parts += ["", "## 3. Responses"]
    if responses:
        parts.extend(
            f"- {esc(e.get('occurred_at') or e.get('recorded_at'))}: "
            f"{esc(e.get('response'))}"
            for e in responses
        )
    else:
        parts.append("- （記録なし）")

    parts += [
        "",
        "## 4. Derived / Inference",
        event_rows(inferred, public=public),
        "",
        "## 5. Claim ledger",
        claim_rows(claims, public=public),
        "",
        "## 6. Reproducibility",
        f"- event_count: {len(events)}",
        f"- observed_raw_count: {len(observed)}",
        f"- derived_inference_count: {len(inferred)}",
        f"- public_redaction_mode: {'on' if public else 'off'}",
        "- source data are not embedded; source_ref is only shown outside public mode.",
        "",
        "## 7. Interpretation boundary",
        "- Observation, external claim, AI answer, inference are separate layers.",
        "- Correlation is not promoted to causation.",
        "- Verification status is preserved instead of silently choosing a single truth.",
        "",
    ]
    return "\n".join(parts)


def main() -> int:
    p = argparse.ArgumentParser(description="Build a Yura Medical Debug Packet")
    p.add_argument("--events", type=Path, required=True, help="debug_event JSONL")
    p.add_argument("--claims", type=Path, help="claim_ledger CSV")
    p.add_argument("--output", type=Path, required=True, help="output Markdown")
    p.add_argument("--from", dest="start", help="ISO datetime lower bound")
    p.add_argument("--to", dest="end", help="ISO datetime upper bound")
    p.add_argument("--tag", help="stressor tag filter")
    p.add_argument("--title", default="Medical Debug Packet")
    p.add_argument("--public", action="store_true", help="suppress source_ref in output")
    args = p.parse_args()

    start = parse_dt(args.start)
    end = parse_dt(args.end)
    if args.start and start is None:
        p.error("--from must be ISO datetime")
    if args.end and end is None:
        p.error("--to must be ISO datetime")

    events = [
        e for e in load_events(args.events)
        if in_range(e, start, end) and has_tag(e, args.tag)
    ]
    claims = load_claims(args.claims)
    packet = build_packet(events, claims, title=args.title, public=args.public)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(packet, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
