# Incident Report: INC-2026-002

## Incident Information
- **Incident ID:** INC-2026-002
- **Date:** September 2026
- **Severity:** Critical
- **Affected Hosts:** 
  - YOURHOST-WIN11 (192.168.56.20)
  - YOURHOST-UBUNTU (192.168.56.30)
- **Primary Analyst:** SOC Tier 2 / IR Team

## Executive Summary
Following a successful initial compromise of the Windows target via compromised RDP credentials, a threat actor established persistence, escalated privileges, dumped LSASS memory for credential harvesting, and moved laterally to the Linux server using `PsExec` or similar SMB-based tools. The attacker actively attempted to cover their tracks by clearing Windows Security logs.

## Full Kill Chain Timeline

| Time (UTC) | Event | Wazuh Rule ID | Details |
|------------|-------|---------------|---------|
| 15:10:00 | Initial Access | N/A | Successful RDP authentication using compromised credentials. |
| 15:12:30 | Execution | `100130` | Encoded PowerShell command executed (Suspicious PowerShell Execution). |
| 15:14:00 | Command & Control | `100140` | `certutil.exe -urlcache -split -f` used to download a payload. |
| 15:15:45 | Persistence | `100150` | Malicious Scheduled Task created to run payload on startup. |
| 15:16:20 | Persistence | `100160` | Registry Run key added for persistence. |
| 15:18:00 | Privilege Escalation | `100110` | UAC bypass utilizing `fodhelper.exe` to spawn high-integrity `cmd.exe`. |
| 15:20:00 | Credential Access | `100180` | `procdump.exe` or similar tool used to access LSASS memory. |
| 15:22:30 | Lateral Movement | `100120` | Remote service creation detected on Linux target (via SMB/PsExec equivalent). |
| 15:25:00 | Defense Evasion | `100170` | Windows Security Event Log cleared (Event ID 1102). |

## Investigation Narrative

### Phase 1: Execution and Persistence
After gaining RDP access, the attacker utilized a base64-encoded PowerShell script to initiate the attack sequence. Shortly after, the native Windows binary `certutil.exe` was used to download additional tooling from an external server. To ensure persistent access across reboots, the attacker scheduled a task and modified the `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` registry key.

### Phase 2: Privilege Escalation and Credential Access
To bypass User Account Control (UAC) without prompting the user, the attacker executed an exploit leveraging `fodhelper.exe`, successfully spawning a high-integrity command prompt. With administrative rights secured, they dumped the memory of the Local Security Authority Subsystem Service (LSASS) to harvest plaintext credentials and NTLM hashes.

### Phase 3: Lateral Movement and Defense Evasion
Using the harvested credentials, the attacker authenticated to the Linux server (`192.168.56.30`) over SMB/RPC, creating a remote service to execute a payload, establishing a foothold on the second system. Finally, to cover their tracks on the Windows host, the attacker issued a command to clear the Windows Security Event log, triggering a critical alert.

## Root Cause Analysis
The initial access vector was compromised RDP credentials, likely obtained through a prior brute force attack or password spraying campaign (see INC-2026-001). Lack of MFA and insufficient network segmentation allowed the attacker to move from the Windows workstation to the Linux server.

## Containment & Remediation

**YOURHOST-WIN11 (192.168.56.20):**
- Host immediately isolated from the network.
- Malicious scheduled tasks and registry Run keys removed.
- Downloaded payloads identified by Sysmon and removed.
- Forced password reset for all local and cached domain accounts.

**YOURHOST-UBUNTU (192.168.56.30):**
- Host isolated from the network.
- Unauthorized services removed and associated malicious binaries deleted.
- Account passwords rotated.
- SSH keys audited and unauthorized keys removed.

## MITRE ATT&CK Mapping
- Initial Access: Valid Accounts (T1078)
- Execution: Command and Scripting Interpreter: PowerShell (T1059.001)
- Persistence: Scheduled Task/Job (T1053.005), Registry Run Keys (T1547.001)
- Privilege Escalation: Bypass User Account Control (T1548.002)
- Credential Access: OS Credential Dumping: LSASS Memory (T1003.001)
- Lateral Movement: Remote Services: SMB/Windows Admin Shares (T1021.002)
- Defense Evasion: Indicator Removal on Host: Clear Windows Event Logs (T1070.001)

## Lessons Learned & Security Improvements
- Implement robust network segmentation to restrict lateral movement between workstations and servers.
- Deploy Endpoint Detection and Response (EDR - Wazuh Sysmon integration proved invaluable here).
- Enforce the principle of least privilege; users should not have local administrator rights by default.
- Implement LAPS (Local Administrator Password Solution) to prevent lateral movement using local admin accounts.
