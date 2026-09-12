# Windows Advanced Audit Policy Configuration Guide

To ensure proper telemetry reaches Wazuh, we need to configure Advanced Audit Policies on the Windows target machine.

## 1. Enable Advanced Auditing Categories

Run Command Prompt as Administrator and execute the following `auditpol` commands to enable crucial logging categories for the lab:

```cmd
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Special Logon" /success:enable
auditpol /set /subcategory:"Process Creation" /success:enable
auditpol /set /subcategory:"Audit Policy Change" /success:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
```

## 2. Enable Command Line Auditing for Process Creation

To see *what* commands were executed when a process starts (Event ID 4688), add this registry key:

```cmd
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f
```

## 3. PowerShell Logging Configuration

PowerShell is a primary attack vector. We must enable Script Block Logging and Module Logging.

### Enable Script Block Logging (Event ID 4104)
```cmd
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
```

### Enable Module Logging (Event ID 4103)
```cmd
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" /v * /t REG_SZ /d * /f
```

## 4. Scheduled Task Creation Auditing

By enabling the object access category, we ensure Scheduled Task actions are logged.
```cmd
auditpol /set /subcategory:"Other Object Access Events" /success:enable /failure:enable
```

## 5. Automation Script (Apply All)

You can save this as `setup-auditing.ps1` and run it from an Administrator PowerShell prompt:

```powershell
# setup-auditing.ps1
Write-Host "[*] Enabling Advanced Audit Policies..."
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Special Logon" /success:enable
auditpol /set /subcategory:"Process Creation" /success:enable
auditpol /set /subcategory:"Audit Policy Change" /success:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Other Object Access Events" /success:enable /failure:enable

Write-Host "[*] Enabling Command Line Auditing..."
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 1 -PropertyType DWORD -Force

Write-Host "[*] Enabling PowerShell Script Block Logging..."
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -PropertyType DWORD -Force

Write-Host "[*] Enabling PowerShell Module Logging..."
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Name "*" -Value "*" -PropertyType String -Force

Write-Host "[+] Audit configuration applied successfully."
```

## 6. Verification

To verify that the settings are applied:

1. Open **Event Viewer** (`eventvwr.msc`).
2. Navigate to **Windows Logs > Security**.
3. Clear the log (to remove old noise).
4. Open a new Command Prompt or PowerShell window and type a command like `whoami`.
5. Refresh the Security log. You should see an **Event ID 4688** (Process Creation).
6. Click on the event, and in the General tab, ensure the **Creator Process Name** and **Process Command Line** contain the command you just executed.

> [!TIP]
> **What Event Viewer should show:** Look for Event 4688. The `Process Information` section in the event details should display `Creator Process Name: C:\Windows\System32\cmd.exe` and `Process Command Line: whoami`.
