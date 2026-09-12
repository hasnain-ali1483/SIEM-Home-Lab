# MITRE ATT&CK Coverage Analysis

## Introduction to MITRE ATT&CK
The MITRE ATT&CK (Adversarial Tactics, Techniques, and Common Knowledge) framework is a globally accessible knowledge base of adversary tactics and techniques based on real-world observations. In this lab environment, we use the ATT&CK framework as our structural foundation for Threat Hunting and Detection Engineering. By mapping our SIEM rules to specific ATT&CK IDs, we ensure comprehensive visibility across the entire kill chain.

## Detection Coverage Matrix

The following custom Wazuh rules (IDs `100100` - `100109`) were engineered to detect the adversary simulation behaviors executed in the previous phase.

| Rule ID | Tactic | Technique | MITRE ID | Telemetry Source | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `100100` | Credential Access | Brute Force: Password Guessing | [T1110.001](https://attack.mitre.org/techniques/T1110/001/) | Windows Security (4625) | Detects multiple failed RDP authentications indicating brute-force. |
| `100101` | Privilege Escalation | Bypass User Access Control | [T1548.002](https://attack.mitre.org/techniques/T1548/002/) | Sysmon (Event ID 1, 13) | Detects UAC bypass via `fodhelper.exe` registry modification. |
| `100102` | Lateral Movement | Remote Services: SMB/Admin Shares | [T1021.002](https://attack.mitre.org/techniques/T1021/002/) | Sysmon (Event ID 3), Suricata | Detects lateral movement via Impacket PsExec and SMB. |
| `100103` | Execution | Command & Scripting: PowerShell | [T1059.001](https://attack.mitre.org/techniques/T1059/001/) | PS Script Block (4104) | Detects base64 encoded payload execution via PowerShell. |
| `100104` | Command & Control | Ingress Tool Transfer | [T1105](https://attack.mitre.org/techniques/T1105/) | Sysmon (Event ID 1) | Detects usage of `certutil.exe` to download remote binaries. |
| `100105` | Persistence | Scheduled Task/Job | [T1053.005](https://attack.mitre.org/techniques/T1053/005/) | Windows Security (4698) | Detects anomalous scheduled task creation. |
| `100106` | Persistence | Boot or Logon Autostart Execution | [T1547.001](https://attack.mitre.org/techniques/T1547/001/) | Sysmon (Event ID 13) | Detects modifications to Registry Run keys. |
| `100107` | Defense Evasion | Indicator Removal: Clear Event Logs | [T1070.001](https://attack.mitre.org/techniques/T1070/001/) | Windows Security (1102) | Detects the execution of `wevtutil cl` to wipe logs. |
| `100108` | Credential Access | OS Credential Dumping: LSASS | [T1003.001](https://attack.mitre.org/techniques/T1003/001/) | Sysmon (Event ID 10) | Detects unauthorized process access to `lsass.exe` memory. |
| `100109` | Execution | Command & Scripting: Unix Shell | [T1059.004](https://attack.mitre.org/techniques/T1059/004/) | Linux auditd / bash logs | Detects suspicious shell commands on the Linux target. |

## ATT&CK Navigator Visualization

To visualize our defensive posture, we can map these techniques onto the ATT&CK Matrix.

1. Navigate to the [MITRE ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/).
2. Click **Create New Layer > Enterprise**.
3. Use the Search feature (magnifying glass) to search for the MITRE IDs listed in the table above (e.g., `T1110.001`).
4. Right-click the technique and assign it a color (e.g., Green) to indicate "Coverage Confirmed".
5. Alternatively, you can save and export the layer as a JSON file and upload it directly to your portfolio repository.

## Coverage Analysis & Gap Assessment

### What is Covered
Our current implementation provides excellent visibility into:
* **Execution & Persistence:** Highly reliable detection of common LOLBin (Living Off The Land Binaries) abuse such as PowerShell, Scheduled Tasks, and Registry modifications, courtesy of Sysmon and detailed Windows Auditing.
* **Defense Evasion:** We can definitively track attempts to blind the SIEM (log clearing).

### What is Missing (Future Improvements)
To mature this SIEM environment, future iterations should focus on detecting:
* **T1055 Process Injection:** While we monitor `CreateRemoteThread` (Sysmon 8), we need tuned rules for specific injection vectors like Process Hollowing or DLL Injection.
* **T1071 Application Layer Protocol (C2):** Currently relying on Suricata signatures. We should integrate threat intelligence feeds (e.g., MISP) directly into Wazuh to detect known malicious C2 domains via DNS logs (Sysmon 22).
* **T1486 Data Encrypted for Impact (Ransomware):** We could implement File Integrity Monitoring (FIM) via Wazuh to detect mass file modifications indicative of ransomware encryption behaviors.
