# PB-002: Privilege Escalation via UAC Bypass

**Alert Source:** Wazuh Rule `100110` (UAC Bypass Attempt Detected)  
**Severity:** Critical  
**MITRE ATT&CK:** [T1548.002 - Bypass User Account Control](https://attack.mitre.org/techniques/T1548/002/)  

## Initial Assessment
This alert indicates that an attacker has attempted to bypass Windows User Account Control (UAC) to execute code with elevated privileges. The analyst will typically observe unusual parent-child process relationships involving native Windows binaries known for UAC bypass vulnerabilities (e.g., `fodhelper.exe`, `eventvwr.exe`, `slui.exe`).

## Investigation Steps

1. **Identify Parent and Child Processes**
   - Examine the alert details for the parent process (e.g., `fodhelper.exe`) and the child process spawned by it (e.g., `cmd.exe`, `powershell.exe`).
2. **Determine User Account Context**
   - Identify the user account under which the processes are running. Does the user typically require elevated privileges?
3. **Trace the Process Ancestry**
   - Determine what spawned the parent process. Was it a suspicious script, an unexpected executable, or an interactive session (RDP/WinRM)?
4. **Look for Prior Indicators of Compromise (IoCs)**
   - Check the host for other alerts preceding the UAC bypass, such as suspicious downloads, brute force attacks, or lateral movement.
5. **Check for Subsequent Escalation Activities**
   - Look for actions typically performed after gaining admin rights: credential dumping (e.g., LSASS access), disabling security software, or creating new administrative accounts.

## Escalation
> [!CAUTION]
> This alert is almost always a True Positive. UAC bypass techniques are rarely used in legitimate administrative workflows. **IMMEDIATELY ESCALATE** this to Tier 2 and the Incident Response team.

## Containment Actions
- **Host Isolation:** Immediately isolate the endpoint from the network to prevent further lateral movement.
- **Evidence Preservation:** Do not reboot the machine or clear logs. Preserve the current state (memory and disk) for forensic analysis.
- **Account Disablement:** Disable the associated user account if it is believed to be compromised.

## Wazuh Dashboard Queries

*Find processes spawned by common UAC bypass binaries:*
```kql
rule.id: "100110" OR (data.win.eventdata.parentImage: *fodhelper.exe* OR data.win.eventdata.parentImage: *eventvwr.exe*)
```
