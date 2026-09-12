# PsExec Lateral Movement Detection

## Threat Scenario
PsExec is a legitimate Sysinternals tool used by IT administrators, but it is heavily abused by adversaries to execute commands on remote systems (lateral movement). When PsExec runs remotely, it drops a service executable (usually `PSEXESVC.exe`) in the Windows folder and creates a new service to execute it.

## MITRE ATT&CK Mapping
- **Tactic**: Lateral Movement (TA0008), Privilege Escalation (TA0004)
- **Technique**: Remote Services (T1021), Create or Modify System Process (T1543)
- **Sub-technique**: SMB/Windows Admin Shares (T1021.002), Windows Service (T1543.003)

## Telemetry Requirements
- Windows System Event 7045 (A service was installed in the system)
- Sysmon Event 1 (Process Creation)

## Detection Logic
- **Rule 100120**: Monitors Event 7045 for the creation of a service containing "PSEXESVC" in its name or image path.
- **Rule 100121**: Monitors Sysmon Event 1 for the execution of `psexec.exe` or `PSEXESVC.exe`.

## Wazuh Rule XML
```xml
<group name="windows, lateral_movement, psexec,">
  <!-- Detect Service Creation via PsExec -->
  <rule id="100120" level="12">
    <if_sid>60100</if_sid> <!-- Windows event base -->
    <field name="win.system.eventID">^7045$</field>
    <field name="win.eventdata.serviceName" type="pcre2">(?i)PSEXESVC</field>
    <description>Lateral Movement: PsExec service installed (Event 7045)</description>
    <mitre>
      <id>T1021.002</id>
      <id>T1543.003</id>
    </mitre>
  </rule>

  <!-- Detect Process Creation of PsExec -->
  <rule id="100121" level="10">
    <if_sid>61603</if_sid> <!-- Sysmon Event 1 -->
    <field name="win.system.eventID">^1$</field>
    <field name="win.eventdata.image" type="pcre2">(?i)(psexec\.exe|PSEXESVC\.exe)$</field>
    <description>Lateral Movement: PsExec process executed</description>
    <mitre>
      <id>T1021.002</id>
    </mitre>
  </rule>
</group>
```

## Validation Procedure
Run Impacket's psexec.py from Kali to the Windows target:
```bash
psexec.py Administrator:Password123!@192.168.56.20 cmd.exe
```

## False Positive Considerations
If IT administrators in the environment use PsExec for regular administrative tasks, this will generate false positives. Tuning may involve whitelisting specific administrative jump boxes by IP or hostname.

## Triage Steps
1. Check the source IP of the PsExec connection (often found in Security Event 4624 Logon Type 3 occurring concurrently).
2. Determine if the source is a known administrative workstation.
3. Review the commands executed immediately following the PsExec service creation.
