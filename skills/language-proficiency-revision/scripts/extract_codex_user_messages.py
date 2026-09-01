#!/usr/bin/env python3
import argparse
import glob
import hashlib
import json
import os
import re
import sys
from datetime import date


def parse_date(value):
    try:
        return date.fromisoformat(value)
    except ValueError:
        raise argparse.ArgumentTypeError(f"invalid date: {value!r}, expected YYYY-MM-DD")


def file_date(path):
    match = re.search(r"rollout-(\d{4})-(\d{2})-(\d{2})T", os.path.basename(path))
    if not match:
        return None
    year, month, day = map(int, match.groups())
    return date(year, month, day)


def text_from_content(content):
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return ""

    chunks = []
    for item in content:
        if not isinstance(item, dict):
            continue
        if item.get("type") in {"input_text", "text"} and isinstance(item.get("text"), str):
            chunks.append(item["text"])
    return "\n".join(chunks)


def looks_like_generated_context(text):
    stripped = text.lstrip()
    return (
        stripped.startswith("<environment_context>")
        or stripped.startswith("# AGENTS.md instructions")
        or stripped.startswith("<skill>")
        or "<INSTRUCTIONS>" in stripped[:1000]
    )


def looks_like_attachment_header(text):
    return text.lstrip().startswith("# Files mentioned by the user:")


def looks_like_link_only(text):
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    return bool(lines) and all(re.fullmatch(r"https?://\S+", line) for line in lines)


def should_skip(text, include_links, include_attachment_headers):
    if not text:
        return True
    if looks_like_generated_context(text):
        return True
    if not include_attachment_headers and looks_like_attachment_header(text):
        return True
    if not include_links and looks_like_link_only(text):
        return True
    return False


def iter_session_files(codex_home, start, end, include_archived):
    roots = [os.path.join(codex_home, "sessions")]
    if include_archived:
        roots.append(os.path.join(codex_home, "archived_sessions"))

    dated_paths = []
    for root in roots:
        for path in glob.glob(os.path.join(root, "**", "*.jsonl"), recursive=True):
            d = file_date(path)
            if d and start <= d <= end:
                dated_paths.append((d, path))
    yield from sorted(dated_paths)


def iter_user_messages(path):
    with open(path, "r", encoding="utf-8") as handle:
        for line in handle:
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                continue
            if not isinstance(record, dict):
                continue

            payload = record.get("payload")
            if not isinstance(payload, dict):
                continue

            text = ""
            if record.get("type") == "response_item":
                if payload.get("type") == "message" and payload.get("role") == "user":
                    text = text_from_content(payload.get("content"))
            elif record.get("type") == "event_msg":
                if payload.get("type") == "user_message":
                    text = payload.get("message", "")

            if isinstance(text, str):
                yield record.get("timestamp", ""), text.strip()


def main():
    parser = argparse.ArgumentParser(description="Extract only user-authored messages from local Codex JSONL sessions.")
    parser.add_argument("--start", required=True, type=parse_date, help="Start date, YYYY-MM-DD.")
    parser.add_argument("--end", required=True, type=parse_date, help="End date, YYYY-MM-DD.")
    parser.add_argument("--codex-home", default=os.path.expanduser("~/.codex"), help="Codex home directory.")
    parser.add_argument("--max-messages", type=int, default=250, help="Maximum messages to print.")
    parser.add_argument("--max-chars", type=int, default=24000, help="Maximum total message characters to print.")
    parser.add_argument("--include-links", action="store_true", help="Include messages that only contain URLs.")
    parser.add_argument("--include-attachment-headers", action="store_true", help="Include app-generated attachment header messages.")
    parser.add_argument("--no-archived", action="store_true", help="Exclude archived_sessions.")
    args = parser.parse_args()

    if args.end < args.start:
        print("--end must be on or after --start", file=sys.stderr)
        return 2

    seen = set()
    files = 0
    emitted = 0
    chars = 0

    for d, path in iter_session_files(args.codex_home, args.start, args.end, not args.no_archived):
        files += 1
        for timestamp, text in iter_user_messages(path):
            if should_skip(text, args.include_links, args.include_attachment_headers):
                continue
            digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
            if digest in seen:
                continue
            seen.add(digest)

            next_chars = chars + len(text)
            if emitted >= args.max_messages or next_chars > args.max_chars:
                print(f"--- TRUNCATED | files_scanned={files} | messages={emitted} | chars={chars}")
                return 0

            emitted += 1
            chars = next_chars
            print(f"--- MESSAGE {emitted} | {d.isoformat()} | {timestamp}")
            print(text)
            print()

    print(f"--- SUMMARY | files_scanned={files} | messages={emitted} | chars={chars}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
