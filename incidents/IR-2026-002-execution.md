# IR-2026-002 — Suspicious PowerShell

**Severity:** Medium | **Status:** Closed — simulated lab incident

## Summary
Synthetic process telemetry contained a PowerShell encoded-command marker.

## Evidence
- Process: `powershell.exe`
- Marker: `-enc`
- Host: `lab-windows`
- User: `labuser`

## Analyst Assessment
The event matched the custom detection. No command was executed by the simulation.

## Tuning
Use parent process, user, script path, signer and known administrative hosts to reduce false positives.
