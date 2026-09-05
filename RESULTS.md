# Lab Results

**Status: Completed — controlled simulated lab validation**

Eight detection scenarios were executed against synthetic endpoint/security telemetry.

| Test | Scenario | Expected | Result |
|---|---|---|---|
| T01 | Failed-login burst | Medium alert | PASS |
| T02 | Failure followed by success | High alert | PASS |
| T03 | Suspicious PowerShell | Medium alert | PASS |
| T04 | New local user | Medium alert | PASS |
| T05 | Privileged group change | High alert | PASS |
| T06 | Scheduled task creation | Medium alert | PASS |
| T07 | Audit log clearing | High alert | PASS |
| T08 | Encoded command marker | Medium alert | PASS |

**Detection validation: 8/8 scenarios passed.**

## Findings

- Authentication correlation provided stronger context than failure counts alone.
- Privilege changes were treated as higher-risk than ordinary account events.
- PowerShell detections require tuning for legitimate administrative automation.
- Persistence detections benefit from user and process context.

## Limitations

This is a home-lab portfolio project. Events are synthetic/simulated and do not represent a production compromise or real SOC performance metrics.
