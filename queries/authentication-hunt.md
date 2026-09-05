# Authentication Hunting

```text
event_type=authentication outcome=failure
| stats count by source_ip
| sort -count
```

```text
event_type=authentication outcome=failure
| stats count by user
| sort -count
```

Investigate source, account privilege, cross-account targeting and post-login activity.
