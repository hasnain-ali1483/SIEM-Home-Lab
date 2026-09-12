# RDP Brute Force Detection

## Threat Scenario
Attackers frequently scan the internet for exposed RDP (Remote Desktop Protocol) services and attempt to brute force passwords using tools like Hydra, Medusa, or custom scripts. A successful brute force grants the attacker interactive access to the system.

## MITRE ATT&CK Mapping
- **Tactic**: Credential Access (TA0006)
- **Technique**: Brute Force (T1110)
- **Sub-technique**: Password Guessing (T1110.001)

## Telemetry Requirements
- Windows Security Event 4625 (Failed Logon)
- Windows Security Event 4624 (Successful Logon)
- (Logon Type 10 for RDP, Logon Type 3 for Network)

## Detection Logic
1. **Rule 100100**: Triggers on individual failed RDP logons.
2. **Rule 100101**: A frequency rule that alerts if 100100 is triggered 5 or more times within 120 seconds from the same source IP.
3. **Rule 100102**: Alerts if a successful RDP logon (4624) occurs from an IP that recently triggered the brute-force rule (100101).

## Wazuh Rule XML
```xml
<group name="windows, credential_access, brute_force,">
  <!-- Parent Rule: RDP Failed Logon -->
  <rule id="100100" level="3">
    <if_sid>60106</if_sid> <!-- Base Windows Logon Failure Rule -->
    <field name="win.system.eventID">^4625$</field>
    <field name="win.eventdata.logonType">^10$|^3$</field>
    <description>RDP or Network Logon Failure (Event 4625)</description>
    <mitre>
      <id>T1110.001</id>
    </mitre>
  </rule>

  <!-- Frequency Rule: Brute Force Detection -->
  <rule id="100101" level="10" frequency="5" timeframe="120">
    <if_matched_sid>100100</if_matched_sid>
    <same_source_ip />
    <description>RDP Brute Force: Multiple failed logons from same source IP within 120 seconds</description>
    <mitre>
      <id>T1110.001</id>
    </mitre>
  </rule>

  <!-- Success after Brute Force -->
  <rule id="100102" level="12">
    <if_sid>60103</if_sid> <!-- Base Windows Logon Success Rule -->
    <field name="win.system.eventID">^4624$</field>
    <field name="win.eventdata.logonType">^10$|^3$</field>
    <if_matched_sid>100101</if_matched_sid>
    <same_source_ip />
    <description>CRITICAL: Successful RDP Logon following Brute Force activity from same IP</description>
    <mitre>
      <id>T1110.001</id>
    </mitre>
  </rule>
</group>
```

## Validation Procedure
Run the following from Kali Linux against the Windows target:
```bash
hydra -l Administrator -P /usr/share/wordlists/rockyou.txt rdp://192.168.56.20
```

## False Positive Considerations
- Administrators mistyping passwords (typically falls below the 5-attempt threshold).
- Misconfigured automated services or scheduled tasks attempting network authentication with expired credentials.

## Triage Steps
1. Identify the source IP of the brute force.
2. Determine if the source IP is internal or external.
3. Check if Rule 100102 triggered, indicating a compromised account.
4. If successful, isolate the host and reset the compromised user's password.
5. If internal, investigate the source machine for malware.
6. Verify Active Response (if enabled) dropped the source IP.
