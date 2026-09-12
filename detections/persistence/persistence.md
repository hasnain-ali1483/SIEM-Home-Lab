# Windows Persistence Mechanisms

## Threat Scenario
To maintain access to a compromised system across reboots, attackers establish persistence. Two of the most common mechanisms are creating malicious Scheduled Tasks (which run payloads at specific times or system start) and modifying Registry Run/RunOnce keys (which execute payloads upon user login).

## MITRE ATT&CK Mapping
- **Tactic**: Persistence (TA0003)
- **Technique**: Scheduled Task/Job (T1053), Boot or Logon Autostart Execution (T1547)
- **Sub-technique**: Scheduled Task (T1053.005), Registry Run Keys (T1547.001)

## Telemetry Requirements
- Windows Security Event 4698 (A scheduled task was created)
- Sysmon Event 13 (Registry Value Set)

## Detection Logic
- **Rule 100150 (Scheduled Task)**: Triggers when Event 4698 shows a task action pointing to a user-writable path like `\Users\`, `\Temp\`, or `\AppData\`. System-level tasks usually run from `System32` or `Program Files`.
- **Rule 100160 (Registry Run Key)**: Monitors Sysmon Event 13 for modifications to `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run` or `RunOnce` (and HKCU equivalents).

## Wazuh Rule XML (Scheduled Task)
```xml
<group name="windows, persistence, scheduled_task,">
  <rule id="100150" level="12">
    <if_sid>60100</if_sid>
    <field name="win.system.eventID">^4698$</field>
    <field name="win.eventdata.Action" type="pcre2">(?i)(\\Users\\|\\Temp\\|\\AppData\\)</field>
    <description>Persistence: Scheduled Task created executing from user-writable path</description>
    <mitre>
      <id>T1053.005</id>
    </mitre>
  </rule>
</group>
```

## Validation Procedure
For Scheduled Tasks:
```cmd
schtasks /create /tn "MaliciousTask" /tr "C:\Users\Public\malware.exe" /sc onlogon
```
For Registry Keys:
Use Atomic Red Team:
```powershell
Invoke-AtomicTest T1547.001
```

## False Positive Considerations
- Legitimate software installers often create scheduled tasks and run keys. Ensure exclusions are specific to known good binary paths and hashes.
- Auto-updating applications like Chrome or Discord use user-writable paths for tasks.

## Triage Steps
1. Identify the file being executed by the persistence mechanism.
2. Extract the file and analyze it in a sandbox or via VirusTotal.
3. Check process execution logs (Sysmon Event 1) to see if the persistence mechanism was triggered and what child processes spawned.
4. Remove the persistence artifact and quarantine the associated files.
