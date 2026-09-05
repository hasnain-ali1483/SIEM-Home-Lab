# IR-2026-001 — Suspicious Authentication

**Severity:** High | **Status:** Closed — simulated lab incident

## Summary
Five failed authentication attempts from one source were followed by a successful login inside the correlation window.

## Evidence
- User: `labuser`
- Source: `10.10.10.50`
- Host: `lab-windows`
- Five failures followed by one success

## Analyst Assessment
The sequence matched the suspicious-authentication hypothesis. Telemetry is synthetic; no real account compromise occurred.

## Response Exercise
Validate the source, review nearby authentication events, inspect post-login activity, document evidence, and close the case.

## Detection Improvement
Correlate failures with successful authentication and privileged-account context.
