# Endpoint Telemetry Configuration

To build an effective SOC environment, endpoints must be configured to generate high-fidelity telemetry. We will configure advanced logging on both Windows and Linux targets.

## WINDOWS TARGET (192.168.56.20)

### 1. Sysmon Installation
System Monitor (Sysmon) provides detailed information about process creation, network connections, and file modifications.

1. Download Sysmon from [Microsoft Sysinternals](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon).
2. Download the highly recommended [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config).
3. Open an administrative PowerShell prompt and run:
```powershell
sysmon64.exe -accepteula -i sysmonconfig-export.xml
```

**Critical Sysmon Event IDs Monitored:**
* `Event ID 1`: Process creation (includes command line parameters)
* `Event ID 3`: Network connection
* `Event ID 7`: Image loaded
* `Event ID 8`: CreateRemoteThread
* `Event ID 10`: ProcessAccess
* `Event ID 11`: FileCreate
* `Event ID 13`: RegistryEvent (Value Set)
* `Event ID 22`: DNSEvent (DNS query)

### 2. Windows Advanced Audit Policy
Using the Local Security Policy editor (`secpol.msc`), configure the following Advanced Audit Policies:
* **Advanced Audit Policy Configuration > System Audit Policies - Local Group Policy Object**
  * **Logon/Logoff**: Audit Logon (Success, Failure), Audit Special Logon (Success)
  * **Detailed Tracking**: Audit Process Creation (Success)
  * **Account Management**: Audit User Account Management (Success, Failure)

**Enable Command Line Auditing:**
Navigate to **Computer Configuration > Administrative Templates > System > Audit Process Creation**.
Enable **"Include command line in process creation events"**.

### 3. PowerShell Logging
Malware heavily relies on PowerShell. We must enable detailed logging to capture decoded payloads and module execution.

Navigate to **Computer Configuration > Administrative Templates > Windows Components > Windows PowerShell**:
* Enable **Turn on Module Logging** (Event ID 4103). Click 'Show' and add `*` for module names.
* Enable **Turn on PowerShell Script Block Logging** (Event ID 4104).

### 4. Wazuh Agent Configuration
Instruct the Wazuh Agent to collect these new logs. Open `C:\Program Files (x86)\ossec-agent\ossec.conf` as Administrator and ensure these `<localfile>` blocks exist:

```xml
  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>

  <localfile>
    <location>Microsoft-Windows-PowerShell/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>

  <localfile>
    <location>Security</location>
    <log_format>eventchannel</log_format>
  </localfile>
  
  <localfile>
    <location>System</location>
    <log_format>eventchannel</log_format>
  </localfile>
```
Restart the Wazuh service from Services (`services.msc`).

---

## LINUX TARGET (192.168.56.30)

### 1. auditd Installation and Configuration
`auditd` is the userspace component to the Linux Auditing System.

```bash
sudo apt update
sudo apt install auditd audispd-plugins -y
```

Add custom rules to monitor critical files and commands. Edit `/etc/audit/rules.d/audit.rules`:
```bash
sudo nano /etc/audit/rules.d/audit.rules
```
Add the following rules:
```text
# Monitor modifications to password files
-w /etc/passwd -p wa -k passwd_mods
-w /etc/shadow -p wa -k shadow_mods

# Monitor sudoers file
-w /etc/sudoers -p wa -k sudoers_mods

# Monitor execution of shell binaries
-w /bin/bash -p x -k bash_exec
-w /bin/sh -p x -k sh_exec
```
Restart the service: `sudo systemctl restart auditd`

### 2. rsyslog Configuration
Ensure auth logs are generated properly. `auth.log` tracks successful and failed logins (SSH).
This is enabled by default on Ubuntu, but verify `/var/log/auth.log` exists.

### 3. Wazuh Agent Configuration
Configure the Linux Wazuh agent to collect the newly generated audit logs. Edit `/var/ossec/etc/ossec.conf`:

```xml
  <localfile>
    <log_format>audit</log_format>
    <location>/var/log/audit/audit.log</location>
  </localfile>
  
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/auth.log</location>
  </localfile>
```
Restart the Wazuh Agent:
```bash
sudo systemctl restart wazuh-agent
```

## Verification
Navigate to the Wazuh Dashboard -> Discover. Filter by `agent.name: "windows-target"` and `agent.name: "linux-target"` to confirm that logs from Sysmon, PowerShell, and auditd are successfully streaming to the SIEM.
