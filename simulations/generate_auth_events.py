#!/usr/bin/env python3
import json
from datetime import datetime, timezone, timedelta

start = datetime.now(timezone.utc)
for i in range(5):
    print(json.dumps({
        "timestamp": (start + timedelta(seconds=i * 10)).isoformat(),
        "event_type": "authentication",
        "outcome": "failure",
        "user": "labuser",
        "source_ip": "10.10.10.50",
        "host": "lab-endpoint"
    }))

print(json.dumps({
    "timestamp": (start + timedelta(seconds=70)).isoformat(),
    "event_type": "authentication",
    "outcome": "success",
    "user": "labuser",
    "source_ip": "10.10.10.50",
    "host": "lab-endpoint"
}))
