#!/usr/bin/env python3
import json, sys

path = sys.argv[1] if len(sys.argv) > 1 else "sample-logs/authentication.jsonl"
with open(path, encoding="utf-8") as f:
    for n, line in enumerate(f, 1):
        try:
            json.loads(line)
        except json.JSONDecodeError as e:
            raise SystemExit(f"Invalid JSON on line {n}: {e}")
print(f"OK: {path}")
