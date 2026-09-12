# Incident Report: INC-2026-001

## Incident Information
- **Incident ID:** INC-2026-001
- **Date:** September 2026
- **Severity:** High
- **Affected Host:** YOURHOST-WIN11 (192.168.56.20)
- **Primary Analyst:** SOC Tier 1

## Executive Summary
An external IP (`192.168.56.50`) conducted an RDP brute force attack against the `Administrator` account on `YOURHOST-WIN11`. After approximately 47 failed attempts over a 3-minute period, the attacker successfully authenticated. The attacker performed basic system enumeration but no lateral movement or data exfiltration was detected prior to containment.

## Alert Timeline (System Time: UTC)
- **14:32:15** — First failed RDP logon detected (Event 4625, Logon Type 3/10).
- **14:32:15 to 14:35:22** — 47 failed logon attempts recorded originating from `192.168.56.50`.
- **14:35:22** — Wazuh Rule `100101` fired (Multiple Failed Logons threshold exceeded).
- **14:35:41** — Successful RDP logon for account 'Administrator' (Event 4624, Logon Type 10).
- **14:35:41** — Wazuh Rule `100102` fired (Successful Logon After Brute Force).

## Investigation Details
Upon receiving the critical alert for a successful logon following a brute force attack (Rule 100102), the analyst queried all authentication and process creation events for the source IP `192.168.56.50`.

1. **Authentication Analysis:** Confirmed 47 failed logons exclusively targeting the 'Administrator' account. The pattern indicated an automated dictionary attack.
2. **Post-Compromise Activity:** Review of Sysmon Event ID 1 (Process Creation) logs revealed that following the successful logon at 14:35:41, the attacker launched `cmd.exe` and executed the following enumeration commands:
   - `whoami`
   - `ipconfig /all`
   - `net user`
3. **Lateral Movement / Exfiltration Check:** Network connections (Sysmon Event ID 3) and Suricata IDS logs showed no outbound connections to unknown IP addresses or anomalous internal traffic. No data archiving tools (e.g., `tar`, `zip`) or suspicious PowerShell scripts were executed.

## Root Cause
- A weak password was configured on the local `Administrator` account.
- RDP (Port 3389) was exposed on the internal network without an account lockout policy in place.

## Containment Actions
- The `Administrator` account was immediately disabled.
- The source IP `192.168.56.50` was blocked at the perimeter firewall.
- Active RDP sessions from the malicious IP were forcefully terminated.

## Remediation
- A strong password policy was enforced across all local accounts.
- An account lockout policy was configured (e.g., lockout after 5 failed attempts for 15 minutes).
- Network Level Authentication (NLA) was confirmed enabled for RDP.

## Lessons Learned
- Implement strict account lockout thresholds to mitigate brute force attacks effectively.
- Consider utilizing Multi-Factor Authentication (MFA) for all remote access mechanisms, including internal RDP sessions.

## Indicators of Compromise (IOCs)
| Type | Value | Description |
|------|-------|-------------|
| IPv4 | `192.168.56.50` | Attacker Source IP |
| User | `Administrator` | Targeted Account |
