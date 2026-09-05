# Detection Tuning Notes

## Authentication
Potential false positives include service accounts and approved automation. Correlate failures with success and unusual source context.

## PowerShell
Legitimate administration may trigger keyword detections. Add parent-process, user, script-path and approved-host context.

## Privilege Changes
Approved onboarding and IT administration can create noise. Maintain change context and elevate unexpected actors.

## Scheduled Tasks
Software updates and management agents may create tasks. Baseline known task names, paths and publishers.
