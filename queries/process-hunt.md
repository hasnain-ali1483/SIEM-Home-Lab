# Process Hunting

```text
process_name=powershell.exe
| search command_line contains ("-enc", "encodedcommand", "downloadstring", "iex")
```

```text
event_type=persistence mechanism=scheduled_task action=created
```

Review user, parent process, command line, path and related network activity.
