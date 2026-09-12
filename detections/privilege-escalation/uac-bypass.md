# UAC Bypass via AutoElevate Binaries

## Threat Scenario
Windows User Account Control (UAC) prevents unauthorized changes. However, certain Microsoft binaries are configured to "AutoElevate" without prompting the user. Attackers abuse these binaries (like `fodhelper.exe` or `eventvwr.exe`) by altering specific Registry keys to hijack their execution flow and launch elevated command prompts or PowerShell sessions.

## MITRE ATT&CK Mapping
- **Tactic**: Privilege Escalation (TA0004), Defense Evasion (TA0005)
- **Technique**: Abuse Elevation Control Mechanism (T1548)
- **Sub-technique**: Bypass User Account Control (T1548.002)

## Telemetry Requirements
- Sysmon Event 1 (Process Creation)

## Detection Logic
**Rule 100110**: Uses PCRE2 regex to detect when `fodhelper.exe`, `eventvwr.exe`, or `slui.exe` (known AutoElevate binaries) spawns a command shell (`cmd.exe`, `powershell.exe`, `pwsh.exe`). Under normal conditions, these binaries do not spawn shells.

## Wazuh Rule XML
```xml
<group name="windows, privilege_escalation, uac_bypass,">
  <rule id="100110" level="14">
    <if_sid>61603</if_sid> <!-- Sysmon Event 1 -->
    <field name="win.system.eventID">^1$</field>
    <field name="win.eventdata.parentImage" type="pcre2">(?i)(fodhelper\.exe|eventvwr\.exe|slui\.exe)$</field>
    <field name="win.eventdata.image" type="pcre2">(?i)(cmd\.exe|powershell\.exe|pwsh\.exe)$</field>
    <description>UAC Bypass: Suspicious child process spawned by AutoElevate executable</description>
    <mitre>
      <id>T1548.002</id>
    </mitre>
  </rule>
</group>
```

## Validation Procedure
Use Atomic Red Team on the Windows target:
```powershell
Invoke-AtomicTest T1548.002 -TestNumbers 1
```

## False Positive Considerations
Very low. Standard administrative tasks using `fodhelper` or `eventvwr` do not typically result in these binaries launching a shell.

## Triage Steps
1. Confirm the user who initiated the action.
2. Investigate the commands executed within the resulting elevated shell.
3. Check registry modifications (Sysmon Event 13) around the time of execution, specifically looking at `HKCU\Software\Classes\ms-settings\Shell\Open\command`.
4. Isolate the machine if unauthorized privilege escalation is confirmed.
