# SIEM Home Lab — SOC Analyst Detection Engineering

> **Completed portfolio project | Controlled simulation | 8/8 detection scenarios validated**

A completed SOC-style SIEM lab focused on centralized telemetry, custom detection engineering, alert triage, threat hunting, and incident-response documentation.

## Project Status

The lab was validated using controlled synthetic endpoint/security telemetry. The repository contains detection rules, simulated evidence, investigation queries, incident reports, tuning notes, ATT&CK mapping, and test results.

## Architecture

```text
Endpoint Telemetry
       |
       v
Log Collector ---> SIEM ---> Detection Rules ---> Alerts
                                      |
                                      v
                              Analyst Investigation
                                      |
                                      v
                              Incident / Case Notes
```

## Completed Detection Scenarios

| ID | Scenario | Severity | Result |
|---|---|---:|---|
| LAB-AUTH-001 | Failed-login burst | Medium | PASS |
| LAB-AUTH-002 | Failures followed by success | High | PASS |
| LAB-EXEC-001 | Suspicious PowerShell | Medium | PASS |
| LAB-ACCOUNT-001 | New local user | Medium | PASS |
| LAB-PRIV-001 | Privilege/group change | High | PASS |
| LAB-PERSIST-001 | Scheduled task creation | Medium | PASS |
| LAB-EVASION-001 | Audit log clearing | High | PASS |
| LAB-EXEC-002 | Encoded command marker | Medium | PASS |

**Validation result: 8/8 simulated scenarios produced the expected detection outcome.**

## Repository Structure

- `detections/` — custom detection rules
- `simulations/` — safe synthetic activity generators
- `sample-logs/` — sanitized simulated telemetry
- `alerts/` — sample generated alerts
- `incidents/` — completed simulated incident reports
- `queries/` — investigation/hunting queries
- `dashboards/` — SOC dashboard design
- `incident-response/` — reusable runbooks and case template
- `docs/` — architecture, methodology, results, tuning and ATT&CK mapping
- `config/` — vendor-neutral collector example
- `scripts/` — validation helper
- `screenshots/` — add screenshots from your own SIEM deployment

## Analyst Workflow

`Telemetry → Detection → Alert → Triage → Correlation → Scope → Response → Closure`

## Skills Demonstrated

- SIEM and security-log analysis
- Detection engineering
- Event correlation
- Alert triage
- Threat hunting
- Incident-response documentation
- Detection tuning and false-positive analysis
- MITRE ATT&CK mapping
- Git/GitHub documentation

## Safety

All activity and evidence in this repository is simulated. The simulation scripts generate synthetic events and do not execute malicious commands or install persistence. Do not run security-testing activity against systems you do not own or have authorization to test.

## Portfolio Evidence

For a stronger GitHub portfolio, add screenshots from your own SIEM showing:
1. Log ingestion
2. Detection-rule configuration
3. Triggered alerts
4. Investigation timeline
5. Dashboard
6. Closed incident

## Resume Bullet

> Built and validated a home SIEM/SOC lab with centralized endpoint telemetry and 8 custom detections covering authentication abuse, PowerShell execution, privilege changes, persistence and audit-log tampering; performed alert triage, threat hunting, ATT&CK mapping and incident documentation using controlled simulated activity.

See `RESULTS.md` for the validation matrix and `incidents/` for completed case investigations.
