#!/usr/bin/env python3
import json
from datetime import datetime, timezone

events = [
    {"timestamp": datetime.now(timezone.utc).isoformat(), "event_type":"process",
     "process_name":"powershell.exe", "command_line":"powershell.exe -enc LAB_SIMULATED_VALUE",
     "user":"labuser", "host":"lab-endpoint"},
    {"timestamp": datetime.now(timezone.utc).isoformat(), "event_type":"process",
     "process_name":"cmd.exe", "command_line":"cmd.exe /c echo SIEM_LAB_TEST",
     "user":"labuser", "host":"lab-endpoint"}
]
for event in events:
    print(json.dumps(event))
