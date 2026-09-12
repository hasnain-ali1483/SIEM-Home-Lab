# Encoded & Suspicious PowerShell Execution

## Threat Scenario
Attackers often use PowerShell to run malicious code in memory without touching the disk (fileless malware). To evade basic string detection and logging, they frequently base64 encode their PowerShell scripts using the `-EncodedCommand` flag, or use cmdlets designed to download and execute code from the internet (e.g., `Net.WebClient`, `IEX`).

## MITRE ATT&CK Mapping
- **Tactic**: Execution (TA0002)
- **Technique**: Command and Scripting Interpreter (T1059)
- **Sub-technique**: PowerShell (T1059.001)

## Telemetry Requirements
- Sysmon Event 1 (Process Creation)
- PowerShell Operational Log Event 4104 (Script Block Logging)

## Detection Logic
- **Rule 100130**: Looks at Sysmon Event 1 command lines for PowerShell executions using flags indicative of encoded payloads (`-enc`, `-EncodedCommand`, `-e`) or the function `FromBase64String`.
- **Rule 100131**: Scans the contents of de-obfuscated script blocks (Event 4104) for malicious keywords like `Invoke-Mimikatz`, `IEX`, `DownloadString`, or `Net.WebClient`.

## Wazuh Rule XML
```xml
<group name="windows, execution, powershell,">
  <!-- Encoded PowerShell Execution -->
  <rule id="100130" level="12">
    <if_sid>61603</if_sid> <!-- Sysmon Event 1 -->
    <field name="win.system.eventID">^1$</field>
    <field name="win.eventdata.image" type="pcre2">(?i)(powershell\.exe|pwsh\.exe)$</field>
    <field name="win.eventdata.commandLine" type="pcre2">(?i)(-enc|-EncodedCommand|-e|FromBase64String)</field>
    <description>Suspicious PowerShell Execution: Encoded command detected</description>
    <mitre>
      <id>T1059.001</id>
    </mitre>
  </rule>

  <!-- Suspicious PowerShell Script Block -->
  <rule id="100131" level="13">
    <if_sid>60100</if_sid> <!-- Base Windows Event -->
    <field name="win.system.eventID">^4104$</field>
    <field name="win.eventdata.scriptBlockText" type="pcre2">(?i)(Invoke-Mimikatz|Invoke-Expression|Net\.WebClient|DownloadString|IEX)</field>
    <description>Suspicious PowerShell Script Block Content (Event 4104)</description>
    <mitre>
      <id>T1059.001</id>
    </mitre>
  </rule>
</group>
```

## Validation Procedure
Run the following PowerShell command on the Windows target:
```powershell
powershell -e JABzAD0ATgBlAHcALQBPAGIAagBlAGMAdAAgAEkATwAuAE0AZQBtAG8AcgB5AFMAdAByAGUAYQBtACgAWwBDAG8AbgB2AGUAcgB0AF0AOgA6AEYAcgBvAG0AQgBhAHMAZQA2ADQAUwB0AHIAaQBuAGcAKAAiAEgA... (use a valid base64 string)
```
Or use Atomic Red Team:
```powershell
Invoke-AtomicTest T1059.001
```

## False Positive Considerations
Some legitimate software management systems or backup agents use encoded PowerShell to avoid character escaping issues in command lines. These may need to be whitelisted by `parentImage`.

## Triage Steps
1. Decode the base64 string to understand the payload. CyberChef is highly recommended.
2. If it's a download cradle (`DownloadString`), check network logs for connections to the specified URL.
3. Isolate the machine if the payload is malicious.

---

## Related Rules
### LOLBAS (Living Off The Land Binaries and Scripts)
Rules `100140`, `100141`, and `100142` monitor for native Windows binaries abused for ingress tool transfer (T1105) and proxy execution (T1218).
- `certutil.exe -urlcache`
- `bitsadmin.exe /transfer`
- `mshta.exe` execution
