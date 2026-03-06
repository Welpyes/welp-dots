#!/usr/bin/env python3

import os, json, sys

log = os.path.join(os.environ.get("TMPDIR", "/tmp"), "notifications.jsonl")

if not os.path.exists(log):
    print("[]")
    sys.exit(0)

entries = []
with open(log) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entries.append(json.loads(line))
        except json.JSONDecodeError:
            continue

entries.reverse()
print(json.dumps(entries))

