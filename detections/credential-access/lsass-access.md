# LSASS Memory Access Detection

## Threat Scenario
The Local Security Authority Subsystem Service (LSASS) manages security policy, active user authentications, and stores credential materials (like NTLM hashes and Kerberos tickets) in memory. Attackers use tools like Mimikatz or ProcDump to access LSASS memory and dump these credentials for lateral movement.

## MITRE ATT&CK Mapping
- **Tactic**: Credential Access (TA0006)
- **Technique**: OS Credential Dumping (T1003)
- **Sub-technique**: LSASS Memory (T1003.001)

## Telemetry Requirements
- Sysmon Event 10 (ProcessAccess)

## Detection Logic
**Rule 100180**: Monitors Sysmon Event 10 for processes opening a handle to `lsass.exe`. It looks for specific `GrantedAccess` masks indicative of memory reading (e.g., `0x1010`, `0x1410`, `0x143a`). It explicitly ignores known, legitimate system processes (like `csrss.exe` and `svchost.exe`) to reduce false positives.

## Wazuh Rule XML
```xml
<group name="windows, credential_access, lsass,">
  <rule id="100180" level="14">
    <if_sid>61612</if_sid> <!-- Sysmon Event 10 ProcessAccess -->
    <field name="win.system.eventID">^10$</field>
    <field name="win.eventdata.targetImage" type="pcre2">(?i)lsass\.exe$</field>
    <field name="win.eventdata.grantedAccess" type="pcre2">^(0x1010|0x1410|0x1438|0x143a)$</field>
    <field name="win.eventdata.sourceImage" type="pcre2" negate="yes">(?i)(csrss\.exe|services\.exe|lsm\.exe|wmiprvse\.exe|svchost\.exe)$</field>
    <description>CRITICAL: Suspicious access to LSASS memory (Credential Dumping)</description>
    <mitre>
      <id>T1003.001</id>
    </mitre>
  </rule>
</group>
```

## Validation Procedure
Use Sysinternals ProcDump to dump LSASS memory:
```cmd
procdump.exe -accepteula -ma lsass.exe lsass.dmp
```
Or use Atomic Red Team:
```powershell
Invoke-AtomicTest T1003.001
```

## False Positive Considerations
Certain endpoint detection and response (EDR) agents or antivirus software may access LSASS. These will need to be specifically whitelisted in the `sourceImage` negate field.

## Triage Steps
1. Identify the `sourceImage` (the process attempting to access LSASS).
2. Investigate the parent process of the `sourceImage`.
3. If the process is unknown or malicious, assume credentials on the host are compromised.
4. Isolate the machine and initiate password resets for any accounts recently logged into that system.
