# SIEM Home Lab - Attack to Detection Matrix

## 1. Attack Matrix

| Attack Phase | MITRE Technique | Tool/Command | Log Source | Wazuh Rule ID | Expected Alert |
|--------------|-----------------|--------------|------------|---------------|----------------|
| Reconnaissance | T1595 - Active Scanning | `nmap -p 22,445,3389` | Suricata | 80100 (Default) | ET SCAN Nmap User-Agent |
| Initial Access | T1110 - Brute Force | `hydra -l Administrator -P wordlist.txt rdp` | Windows Event Log (4625) | 100100 | Failed RDP Login Attempt |
| Initial Access | T1110 - Brute Force | `hydra -l root -P wordlist.txt ssh` | Linux auth.log | 5712 (Default) | sshd: brute force trying to get access to the system. |
| Execution | T1059.001 - PowerShell | `powershell.exe -enc <Base64>` | Sysmon (Event ID 1) / PowerShell | 100130 | Suspicious Encoded PowerShell Execution |
| Persistence | T1053.005 - Scheduled Task | `schtasks /create` | Sysmon (Event ID 1) / Security (4698) | 100150 | Scheduled Task Created |
| Persistence | T1547.001 - Registry Run Key | `Set-ItemProperty ... Run` | Sysmon (Event ID 13) | 100160 | Registry Run Key Persistence |
| Command & Control | T1105 - Ingress Tool Transfer | `certutil -urlcache -split -f` | Sysmon (Event ID 1) | 100140 | Suspicious Certutil Download |
| Defense Evasion | T1070.001 - Clear Event Logs | `wevtutil cl Application` | Windows Security (1102) | 100170 | Windows Event Log Cleared |
| Lateral Movement | T1021.002 - SMB/Windows Admin Shares | `impacket-psexec` | Sysmon (Event ID 1) / Syslog | 100120 | PsExec Lateral Movement Detected |

## 2. Detection Gap Analysis

- **Memory Dumping (LSASS)**: While Procdump can be flagged if rules are explicitly created for it, advanced LSASS dumping techniques (e.g. via direct system calls) might evade standard Sysmon configurations unless Sysmon Event ID 10 (Process Access) is meticulously tuned.
- **UAC Bypass**: Certain modern UAC bypass techniques that avoid creating new processes on disk may go undetected if Wazuh relies solely on Sysmon Event ID 1. Advanced EDR capabilities are typically required.
- **Data Exfiltration**: Standard Windows logs and Sysmon do not automatically capture network payloads. Without robust TLS decryption and detailed NetFlow analysis, detecting data exfiltration over encrypted channels (e.g., HTTPS) remains a significant gap.

## 3. Test Results Template

| Test | Technique | Expected Rule | Actual Rule Fired | Status (Pass/Fail) | Notes |
|------|-----------|---------------|-------------------|--------------------|-------|
| 1 | T1110 | 100100 | | | |
| 2 | T1059.001 | 100130 | | | |
| 3 | T1053.005 | 100150 | | | |
| 4 | T1547.001 | 100160 | | | |
| 5 | T1105 | 100140 | | | |
| 6 | T1070.001 | 100170 | | | |
| 7 | T1021.002 | 100120 | | | |

## 4. Expected Alert Timeline

During a full kill chain simulation, alerts should ideally populate the Wazuh dashboard in the following sequence:

1. **Reconnaissance** (T0): Suricata flags Nmap scanning (few seconds).
2. **Initial Access** (T+1 min): Multiple failed login attempts (Rule 100100) are registered.
3. **Execution & C2** (T+3 mins): A payload is downloaded via certutil (Rule 100140) and executed using encoded PowerShell (Rule 100130).
4. **Persistence** (T+5 mins): Registry Run keys (Rule 100160) and Scheduled Tasks (Rule 100150) are established.
5. **Lateral Movement** (T+10 mins): Impacket psexec is detected across the network (Rule 100120).
6. **Defense Evasion** (T+15 mins): Attacker attempts to cover tracks by clearing logs (Rule 100170).

*Note: There is typically a 10-30 second delay between the execution of an attack and the visualization of the alert on the Wazuh dashboard due to log parsing and indexing pipelines.*
