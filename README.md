# SIEM Home Lab — Detection Engineering & Adversary Simulation

![Wazuh](https://img.shields.io/badge/Wazuh-4.5+-blue?style=flat-square&logo=wazuh)
![Suricata](https://img.shields.io/badge/Suricata-7.0+-orange?style=flat-square)
![Sysmon](https://img.shields.io/badge/Sysmon-15.0+-lightgrey?style=flat-square&logo=windows)
![Kali Linux](https://img.shields.io/badge/Kali_Linux-2024.1-blue?style=flat-square&logo=kalilinux)

## Project Overview
This project demonstrates the design, implementation, and operation of a localized Security Information and Event Management (SIEM) and Extended Detection and Response (XDR) environment. Utilizing Wazuh, Suricata, and Sysmon, this lab simulates a realistic enterprise network environment under attack. It showcases advanced endpoint telemetry collection, network traffic analysis, custom detection engineering based on the MITRE ATT&CK framework, and hands-on adversary simulation. The primary objective is to highlight practical SOC (Security Operations Center) analyst skills, including threat hunting, log analysis, and incident triage.

## Lab Architecture
The lab environment consists of four Virtual Machines running within VirtualBox, connected via an isolated Host-Only network to ensure safe adversary simulation.

```text
                                 Host-Only Network (192.168.56.0/24)
                                 -----------------------------------
                                                 |
         +------------------------+              |             +------------------------+
         |      SIEM Server       |              |             |    Attacker Machine    |
         | (Ubuntu Server 24.04)  |--------------+-------------|      (Kali Linux)      |
         |     192.168.56.10      |              |             |      192.168.56.50     |
         +------------------------+              |             +------------------------+
         - Wazuh Manager / XDR                   |
         - Suricata NIDS                         |
                                                 |
         +------------------------+              |             +------------------------+
         |     Windows Target     |              |             |      Linux Target      |
         | (Windows 11 Enterprise)|--------------+-------------| (Ubuntu Server 22.04)  |
         |     192.168.56.20      |                            |      192.168.56.30     |
         +------------------------+                            +------------------------+
         - Wazuh Agent                                         - Wazuh Agent
         - Sysmon                                              - auditd / rsyslog
```

## Technologies Used
* **Wazuh SIEM/XDR**: Centralized log collection, alert generation, and endpoint response.
* **Sysmon (System Monitor)**: Advanced Windows endpoint telemetry (process creation, network connections, file modifications).
* **Suricata IDS**: Network Intrusion Detection System for monitoring malicious traffic patterns.
* **Kali Linux**: Offensive security platform used for adversary simulation.
* **Atomic Red Team**: Library of simple, testable attacks mapped to the MITRE ATT&CK framework.
* **VirtualBox**: Type-2 hypervisor utilized for virtual machine provisioning and network isolation.

## Detection Rules
The following custom detection rules were engineered and validated during the adversary simulation phase.

| Rule ID | MITRE ATT&CK ID | Technique Name | Detection Description |
| :--- | :--- | :--- | :--- |
| `100100-100102` | T1110.001 | Brute Force: Password Guessing | Detects multiple failed RDP logon attempts from a single source, alerts on successful logon after brute force. |
| `100110` | T1548.002 | Bypass User Access Control | Detects UAC bypass via auto-elevating binaries (fodhelper, eventvwr, slui) spawning shells. |
| `100120-100121` | T1021.002 | Remote Services: SMB/Windows Admin Shares | Detects lateral movement via PsExec service creation and remote SMB execution. |
| `100130-100131` | T1059.001 | PowerShell: Encoded Commands | Detects encoded PowerShell execution and suspicious Script Block content. |
| `100140-100142` | T1105 / T1218 | Ingress Tool Transfer / LOLBAS | Detects file downloads via certutil, bitsadmin, and mshta execution. |
| `100150` | T1053.005 | Scheduled Task/Job | Detects scheduled task creation executing binaries from user-writable paths. |
| `100160` | T1547.001 | Registry Run Keys | Detects modifications to Run/RunOnce autostart registry keys. |
| `100170-100171` | T1070.001 | Clear Windows Event Logs | Detects audit log clearing via Event ID 1102 and wevtutil commands. |
| `100180` | T1003.001 | LSASS Memory Dumping | Detects suspicious process access to lsass.exe for credential theft. |
| `100190-100192` | T1059.004 | Unix Shell: Reverse Shell | Detects common reverse shell patterns (bash, netcat, python, perl). |

## Skills Demonstrated
* **Detection Engineering**: Creating precise, actionable alerts mapped to MITRE ATT&CK.
* **Log Analysis**: Correlating complex events across Sysmon, Windows Event Logs, auditd, and Suricata.
* **Endpoint Telemetry**: Configuring advanced logging mechanisms on Windows (Sysmon, Script Block Logging) and Linux (auditd).
* **Network Intrusion Detection**: Deploying and configuring Suricata to monitor subnet traffic.
* **MITRE ATT&CK Mapping**: Analyzing behaviors and mapping them to attacker tactics and techniques.
* **Adversary Simulation**: Safely executing advanced persistent threat (APT) techniques.
* **Incident Response & Triage**: Developing playbook-driven responses to confirmed security incidents.

## Getting Started
Follow the documentation in the `docs/` directory to replicate this lab environment:
1. [Lab Setup & Network Configuration](docs/01-lab-setup.md)
2. [SIEM Installation (Wazuh & Suricata)](docs/02-siem-installation.md)
3. [Endpoint Configuration (Windows & Linux)](docs/03-endpoint-config.md)
4. [Adversary Simulation & Attack Execution](docs/04-attack-simulation.md)
5. [MITRE ATT&CK Coverage Analysis](docs/05-mitre-coverage.md)

## Repository Structure
```text
.
├── README.md
├── docs/
│   ├── 01-lab-setup.md                # VirtualBox + VM setup guide
│   ├── 02-siem-installation.md        # Wazuh & Suricata installation
│   ├── 03-endpoint-config.md          # Sysmon, auditd, agent deployment
│   ├── 04-attack-simulation.md        # Kill chain attack procedures
│   └── 05-mitre-coverage.md           # ATT&CK coverage analysis
├── configs/
│   ├── sysmon/
│   │   └── sysmonconfig.xml           # Windows endpoint telemetry config
│   ├── wazuh/
│   │   ├── ossec.conf                 # Wazuh manager configuration
│   │   └── agent.conf                 # Centralized agent group config
│   ├── suricata/
│   │   └── suricata.yaml              # Network IDS configuration
│   └── windows/
│       └── audit-policy.md            # GPO & audit policy guide
├── detections/
│   ├── README.md                      # Detection engineering methodology
│   ├── credential-access/
│   │   ├── brute-force-rdp.xml        # T1110.001 — Brute Force
│   │   ├── brute-force-rdp.md
│   │   ├── lsass-access.xml           # T1003.001 — LSASS Dumping
│   │   └── lsass-access.md
│   ├── privilege-escalation/
│   │   ├── uac-bypass.xml             # T1548.002 — UAC Bypass
│   │   └── uac-bypass.md
│   ├── lateral-movement/
│   │   ├── psexec-detection.xml       # T1021.002 — PsExec / SMB
│   │   └── psexec-detection.md
│   ├── execution/
│   │   ├── encoded-powershell.xml     # T1059.001 — Encoded PowerShell
│   │   ├── encoded-powershell.md
│   │   ├── lolbas-certutil.xml        # T1105 — Certutil Download
│   │   ├── linux-reverse-shell.xml    # T1059.004 — Reverse Shell
│   │   └── linux-reverse-shell.md
│   ├── persistence/
│   │   ├── scheduled-task.xml         # T1053.005 — Scheduled Task
│   │   ├── registry-run-key.xml       # T1547.001 — Registry Run Key
│   │   └── persistence.md
│   └── defense-evasion/
│       ├── log-clearing.xml           # T1070.001 — Log Tampering
│       └── log-clearing.md
├── attack-simulations/
│   ├── atomic-red-team/
│   │   └── run-atomics.ps1            # Automated Atomic RT execution
│   ├── manual-attacks/
│   │   ├── brute-force-hydra.sh       # Hydra brute force script
│   │   ├── lateral-movement.sh        # Impacket lateral movement
│   │   └── persistence-implant.ps1    # Windows persistence simulation
│   └── attack-matrix.md              # Attack-to-detection mapping
├── playbooks/
│   ├── PB-001-BruteForce.md           # Tier 1 SOC Triage Playbook
│   ├── PB-002-UACBypass.md
│   ├── PB-003-LateralMovement.md
│   └── PB-004-LogTampering.md
├── incident-reports/
│   ├── INC-2026-001-BruteForce.md     # Full investigation walkthrough
│   └── INC-2026-002-LateralMovement.md
└── mitre-attack/
    └── navigator-layer.json           # ATT&CK Navigator heatmap layer
```
