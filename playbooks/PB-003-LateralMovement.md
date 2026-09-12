# PB-003: Lateral Movement via Remote Service Creation

**Alert Source:** Wazuh Rule `100120` / `100121`  
**Severity:** High  
**MITRE ATT&CK:** [T1021.002 - SMB/Windows Admin Shares](https://attack.mitre.org/techniques/T1021/002/), [T1543.003 - Windows Service](https://attack.mitre.org/techniques/T1543/003/)  

## Initial Assessment
The analyst will see an alert for a new Windows service being created on a host, potentially from a remote location. This is a common method for attackers to move laterally and execute arbitrary code on remote systems.

## Investigation Steps

1. **Identify the Service Details**
   - Note the newly created service name and the executable path (ImagePath).
2. **Analyze the Executable Path**
   - Does the service binary exist in a legitimate path (e.g., `C:\Windows\System32`) or a user-writable/temp location (e.g., `C:\Users\Public`, `C:\Windows\Temp`)?
3. **Correlate with Authentication Events**
   - Look for successful network logons (Event ID 4624, Logon Type 3) around the same time to identify the source IP and source host.
4. **Look for Known Tools**
   - Check if the service name or executable resembles known lateral movement tools (e.g., `PSEXESVC.exe`, `winexesvc.exe`).
5. **Check for Exfiltration or Further Movement**
   - Review network connections and subsequent process creations from the newly compromised host to see if the attacker is continuing to move laterally or exfiltrating data.

## Escalation Criteria
- If the service creation is confirmed to be unauthorized and originates from an unexpected internal host, escalate to Tier 2 immediately.

## Containment Actions
- **Network Isolation:** Isolate both the source host (where the attack originated) and the destination host (where the service was created).
- **Credential Rotation:** Force a password reset for the account used to authenticate and create the service.
- **Service Removal:** If authorized and confirmed malicious, stop and delete the unauthorized service, and remove the associated executable.

## Wazuh Dashboard Queries

*Find service creation events:*
```kql
rule.id: "100120" OR data.win.system.eventID: "7045"
```

*Correlate with network logons:*
```kql
data.win.system.eventID: "4624" AND data.win.eventdata.logonType: "3" AND data.win.eventdata.targetUserName: "Administrator"
```
