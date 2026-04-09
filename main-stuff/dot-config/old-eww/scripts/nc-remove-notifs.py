#!/usr/bin/env python3
import os, json, sys

if len(sys.argv) < 2:
    sys.exit(1)

target_ts = sys.argv[1]
log = os.path.join(os.environ.get("TMPDIR", "/tmp"), "notifications.jsonl")

if not os.path.exists(log):
    sys.exit(0)

kept = []
removed = False
with open(log) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
            # match on timestamp, remove only the first match
            if not removed and entry.get("timestamp") == target_ts:
                removed = True
                continue
            kept.append(line)
        except json.JSONDecodeError:
            kept.append(line)

with open(log, "w") as f:
    f.write("\n".join(kept))
    if kept:
        f.write("\n")
