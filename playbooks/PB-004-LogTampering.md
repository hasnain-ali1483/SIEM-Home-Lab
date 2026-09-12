# PB-004: Audit Log Tampering / Clearing

**Alert Source:** Wazuh Rule `100170` / `100171`  
**Severity:** Critical  
**MITRE ATT&CK:** [T1070.001 - Indicator Removal on Host: Clear Windows Event Logs](https://attack.mitre.org/techniques/T1070/001/)  

## Initial Assessment
> [!IMPORTANT]  
> Log clearing is **NEVER** normal in a production environment. This is always a strong indicator of active compromise and an attacker attempting to cover their tracks.

The analyst will observe alerts indicating that the Windows Security Event log (Event ID 1102) or System Event log (Event ID 104) has been cleared.

## Investigation Steps

1. **Identify the Actor (WHO)**
   - Examine the Event ID 1102 details to identify the Subject User Name and Domain. This tells you which account cleared the logs.
2. **Review Preceding Events (WHAT)**
   - This is a **RACE** against the attacker. Check what other events occurred on this host just BEFORE the logs were cleared.
   - Did the attacker run a specific command (e.g., `wevtutil cl Security`)?
3. **Correlate with Uncleared Logs**
   - Attackers often clear the Security log but forget to clear Sysmon or PowerShell Script Block Logging. Review Sysmon logs (Event ID 1) for process creations leading up to the log clearing.
4. **Check Network IDS (Suricata)**
   - Review Suricata logs in Wazuh for any corroborating network evidence (e.g., C2 traffic, lateral movement) involving the affected host.

## Immediate Actions
- **Isolate Host:** Immediately isolate the endpoint from the network to stop ongoing attacker activity.
- **Escalate:** Escalate immediately to the Incident Response team (Tier 2/3).
- **Preserve Evidence:** Ensure that Sysmon, Suricata, and other uncleared logs are safely archived. Do not power off the machine unless instructed by IR.

## Wazuh Dashboard Queries

*Find event log clearing activities:*
```kql
rule.id: ("100170" OR "100171") OR data.win.system.eventID: ("1102" OR "104")
```
