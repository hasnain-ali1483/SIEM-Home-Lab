# PB-001: Brute Force Authentication Attack

**Alert Source:** Wazuh Rule `100101` (Multiple Failed Logons) / `100102` (Success After Brute Force)  
**Severity:** High / Critical  
**MITRE ATT&CK:** [T1110.001 - Brute Force: Password Guessing](https://attack.mitre.org/techniques/T1110/001/)  

## Initial Assessment
When this alert fires, the analyst will observe a high volume of failed authentication events originating from a single source IP targeting one or more user accounts, potentially followed by a successful logon event.

## Investigation Steps

1. **Check Source IP Reputation**
   - Is the source IP internal or external? 
   - Check threat intelligence feeds (e.g., VirusTotal, AbuseIPDB) for external IPs.
2. **Query Wazuh for Source IP Events**
   - Retrieve all events from the source IP in the last hour.
3. **Analyze the Targeted Account(s)**
   - Are the targeted accounts privileged (e.g., Administrator, root, service accounts)?
   - Are multiple different accounts being targeted (password spraying) or just one?
4. **Determine if the Attack was Successful**
   - Look for successful authentication events (Windows Event ID 4624) immediately following the failed attempts (Windows Event ID 4625).
5. **Check for Post-Compromise Activity** (If Successful)
   - Review process creation logs (Sysmon Event ID 1 / Windows Event ID 4688).
   - Look for commands like `whoami`, `net user`, `ipconfig`, or unusual PowerShell execution.
   - Check for lateral movement or persistence mechanisms.

## Wazuh Dashboard Queries
Use the following KQL queries in the Wazuh Discover tab:

*Find all authentication failures from the suspected IP:*
```kql
rule.id: "60122" OR rule.id: "60204" AND data.srcip: "192.168.56.50"
```
*(Note: standard rules 60122/60204 correspond to authentication failures)*

*Find successful logons following failures:*
```kql
rule.id: "100102" AND data.srcip: "192.168.56.50"
```

## Decision Flowchart

```text
[Alert: Brute Force Detected]
       |
       v
[Is there a subsequent successful logon?]
  /                                \
YES                                 NO
 /                                   \
[High/Critical Severity]         [Medium Severity]
- Check for post-compromise      - Block source IP
- Disable account                - Close ticket
- Escalate to Tier 2
```

## Containment Actions
- **Network Isolation:** Block the malicious source IP at the firewall or via Wazuh Active Response.
- **Account Actions:** Temporarily disable the compromised account and force a password reset.
- **Service Restriction:** Restrict RDP/SSH access to the host from external networks.

## Escalation Criteria
Escalate to Tier 2 if:
- A successful authentication event occurs after the brute force attempts.
- The targeted account is a Domain Admin, Local Admin, or critical service account.
- Post-compromise activity (e.g., unusual processes, registry modifications) is observed.

## Documentation Requirements
Ensure the following details are logged in the ticketing system:
- Source IP address and reputation analysis.
- Targeted usernames.
- Start and end time of the attack.
- Outcome (Success/Failure).
- Any observed post-compromise activities.
- Containment actions taken (e.g., IP blocked, account disabled).
