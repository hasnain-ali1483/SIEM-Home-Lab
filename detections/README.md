# SIEM Home Lab - Detection Engineering

## Overview
This repository contains the detection engineering rules for the SIEM Home Lab project. The detection lifecycle focuses on mapping telemetry to threat scenarios, creating robust logic based on MITRE ATT&CK techniques, validating the rules with atomic tests, and tuning to reduce false positives.

## Documentation Standard
Each detection rule (except closely related ones which are grouped) has an accompanying Markdown documentation file containing:
- **Threat Scenario**: Context on how an attacker uses the technique.
- **MITRE ATT&CK Mapping**: Tactic, Technique, and Sub-technique.
- **Telemetry Requirements**: Logs and events needed.
- **Detection Logic**: Explanation of the Wazuh rule structure.
- **Wazuh Rule XML**: The actual rule XML.
- **Validation Procedure**: Exact commands or tools (e.g., Atomic Red Team, Kali Linux) to trigger the alert.
- **False Positive Considerations**: Normal activities that might trigger the rule.
- **Triage Steps**: Actions a Tier 1 analyst should take upon seeing the alert.

## Detection Rules Index

| Rule ID | MITRE ID | Name | Category | Logic File | Documentation |
|---------|----------|------|----------|------------|---------------|
| 100100  | T1110.001| RDP Brute Force | Credential Access | [brute-force-rdp.xml](credential-access/brute-force-rdp.xml) | [brute-force-rdp.md](credential-access/brute-force-rdp.md) |
| 100110  | T1548.002| UAC Bypass | Privilege Escalation | [uac-bypass.xml](privilege-escalation/uac-bypass.xml) | [uac-bypass.md](privilege-escalation/uac-bypass.md) |
| 100120  | T1021.002, T1543.003 | PsExec Detection | Lateral Movement | [psexec-detection.xml](lateral-movement/psexec-detection.xml) | [psexec-detection.md](lateral-movement/psexec-detection.md) |
| 100130  | T1059.001| Encoded PowerShell | Execution | [encoded-powershell.xml](execution/encoded-powershell.xml) | [encoded-powershell.md](execution/encoded-powershell.md) |
| 100140  | T1105, T1218 | LOLBAS Certutil & Bitsadmin | Execution | [lolbas-certutil.xml](execution/lolbas-certutil.xml) | (See Encoded PowerShell) |
| 100150  | T1053.005| Scheduled Task Persistence | Persistence | [scheduled-task.xml](persistence/scheduled-task.xml) | [persistence.md](persistence/persistence.md) |
| 100160  | T1547.001| Registry Run Key | Persistence | [registry-run-key.xml](persistence/registry-run-key.xml) | (See Persistence) |
| 100170  | T1070.001| Log Clearing | Defense Evasion | [log-clearing.xml](defense-evasion/log-clearing.xml) | [log-clearing.md](defense-evasion/log-clearing.md) |
| 100180  | T1003.001| LSASS Memory Access | Credential Access | [lsass-access.xml](credential-access/lsass-access.xml) | [lsass-access.md](credential-access/lsass-access.md) |
| 100190  | T1059.004| Linux Reverse Shell | Execution | [linux-reverse-shell.xml](execution/linux-reverse-shell.xml) | [linux-reverse-shell.md](execution/linux-reverse-shell.md) |

## Deployment Instructions
To deploy these rules to Wazuh:
1. Copy the `.xml` files to `/var/ossec/etc/rules/local_rules.xml` on the Wazuh Manager.
2. Restart the Wazuh manager service:
   `systemctl restart wazuh-manager`
