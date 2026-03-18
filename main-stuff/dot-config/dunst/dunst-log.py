#!/bin/env python

import sys
import json
import os
import subprocess
import hashlib
from datetime import datetime

base_dir = os.environ.get("TMPDIR", "/tmp")
LOG_FILE = os.path.join(base_dir, "notifications.jsonl")
ICON_CACHE = os.path.join(base_dir, "eww-icon-cache")

def resolve_icon(icon_path):
    if not icon_path:
        return ""
    if not icon_path.endswith(".svg"):
        return icon_path
    os.makedirs(ICON_CACHE, exist_ok=True)
    h = hashlib.md5(icon_path.encode()).hexdigest()[:8]
    out = os.path.join(ICON_CACHE, f"{h}.png")
    if not os.path.exists(out):
        subprocess.run(
            ["rsvg-convert", "-w", "22", "-h", "22", icon_path, "-o", out],
            capture_output=True
        )
    return out if os.path.exists(out) else ""

def log_notification():
    try:
        data = {
            "timestamp": datetime.now().isoformat(),
            "appname":   sys.argv[1] if len(sys.argv) > 1 else "Unknown",
            "summary":   sys.argv[2] if len(sys.argv) > 2 else "",
            "body":      sys.argv[3] if len(sys.argv) > 3 else "",
            "icon":      resolve_icon(sys.argv[4] if len(sys.argv) > 4 else ""),
            "urgency":   sys.argv[5] if len(sys.argv) > 5 else "NORMAL",
        }
        with open(LOG_FILE, "a") as f:
            f.write(json.dumps(data) + "\n")
    except Exception as e:
        with open(os.path.expanduser("~/dunst_error.log"), "a") as err:
            err.write(f"Error: {str(e)}\n")

if __name__ == "__main__":
    log_notification()
