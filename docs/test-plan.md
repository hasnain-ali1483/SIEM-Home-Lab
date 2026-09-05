# Detection Test Plan

| ID | Scenario | Expected | Result |
|---|---|---|---|
| T01 | Repeated failed logins | Authentication alert | PASS |
| T02 | Failures followed by success | Correlation alert | PASS |
| T03 | PowerShell marker | Execution alert | PASS |
| T04 | Local user creation | Account alert | PASS |
| T05 | Privilege change | High-risk alert | PASS |
| T06 | Scheduled task | Persistence alert | PASS |
| T07 | Audit log clearing | Evasion alert | PASS |
| T08 | Encoded command marker | Execution alert | PASS |
