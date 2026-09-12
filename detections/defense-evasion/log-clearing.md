# Windows Event Log Clearing

## Threat Scenario
To cover their tracks and destroy forensic evidence, attackers frequently clear the Windows Security, System, and Application event logs. This is a massive red flag, as regular users have no reason to clear logs, and even administrators rarely do so outside of specific maintenance windows.

## MITRE ATT&CK Mapping
- **Tactic**: Defense Evasion (TA0005)
- **Technique**: Indicator Removal on Host (T1070)
- **Sub-technique**: Clear Windows Event Logs (T1070.001)

## Telemetry Requirements
- Windows Security Event 1102 (The audit log was cleared)
- Windows System Event 104 (The log file was cleared)
- Sysmon Event 1 (Process Creation)

## Detection Logic
- **Rule 100170**: Immediately alerts at Maximum Severity (Level 15) if Event 1102 or 104 is generated.
- **Rule 100171**: Detects the use of the `wevtutil` command-line utility with the `cl` (clear-log) flag via Sysmon Event 1.

## Wazuh Rule XML
```xml
<group name="windows, defense_evasion, log_clearing,">
  <!-- Windows Native Event Log Cleared -->
  <rule id="100170" level="15">
    <if_sid>60100</if_sid>
    <field name="win.system.eventID">^1102$|^104$</field>
    <description>CRITICAL: Windows Event Log Cleared (Event 1102 or 104)</description>
    <mitre>
      <id>T1070.001</id>
    </mitre>
  </rule>

  <!-- Wevtutil Execution -->
  <rule id="100171" level="14">
    <if_sid>61603</if_sid>
    <field name="win.system.eventID">^1$</field>
    <field name="win.eventdata.image" type="pcre2">(?i)wevtutil\.exe$</field>
    <field name="win.eventdata.commandLine" type="pcre2">(?i) cl | clear-log </field>
    <description>CRITICAL: wevtutil executed to clear event logs</description>
    <mitre>
      <id>T1070.001</id>
    </mitre>
  </rule>
</group>
```

## Validation Procedure
Run the following from an elevated command prompt on the Windows target:
```cmd
wevtutil cl Security
```

## False Positive Considerations
Zero. Log clearing should never happen in a production environment outside of tightly controlled and scheduled maintenance. Any alert should be considered a true positive security incident until proven otherwise.

## Triage Steps
1. Isolate the affected host from the network immediately.
2. Identify the user account that executed the log clearing.
3. Review logs leading up to the clear event (centrally stored in Wazuh/Elasticsearch, as local logs are gone).
4. Initiate a full forensic investigation on the host.
