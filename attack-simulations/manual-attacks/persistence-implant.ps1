<#
.SYNOPSIS
    Simulates persistence and defense evasion mechanisms on the Windows target.
.DESCRIPTION
    Creates scheduled tasks, registry run keys, downloads files, and executes encoded commands.
.NOTES
    WARNING: ONLY RUN IN ISOLATED LAB ENVIRONMENT.
#>

Write-Host "WARNING: Only run this script in an isolated lab environment." -ForegroundColor Red

Function Create-ScheduledTaskPersistence {
    Write-Host "[*] Creating Scheduled Task Persistence..." -ForegroundColor Cyan
    $ImplantPath = "C:\Users\Public\implant.ps1"
    "Write-Output 'Implant running at $(Get-Date)' >> C:\Users\Public\implant.log" | Out-File $ImplantPath -Encoding ascii
    schtasks /create /tn "BenignImplant" /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File $ImplantPath" /sc onlogon /ru "SYSTEM" /f
    Write-Host "[+] Expected Alert: Rule 100150" -ForegroundColor Yellow
}

Function Create-RegistryRunKey {
    Write-Host "[*] Creating Registry Run Key Persistence..." -ForegroundColor Cyan
    $ImplantPath = "C:\Users\Public\implant.ps1"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "BenignImplant" -Value "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File $ImplantPath"
    Write-Host "[+] Expected Alert: Rule 100160" -ForegroundColor Yellow
}

Function Simulate-CertutilDownload {
    Write-Host "[*] Simulating Certutil Download..." -ForegroundColor Cyan
    certutil -urlcache -split -f "https://raw.githubusercontent.com/redcanaryco/atomic-red-team/master/README.md" C:\Users\Public\README.txt
    Write-Host "[+] Expected Alert: Rule 100140" -ForegroundColor Yellow
}

Function Execute-EncodedPowerShell {
    Write-Host "[*] Executing Encoded PowerShell..." -ForegroundColor Cyan
    $Command = "Write-Host 'Hello World'"
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Command)
    $EncodedText = [Convert]::ToBase64String($Bytes)
    powershell.exe -enc $EncodedText
    Write-Host "[+] Expected Alert: Rule 100130" -ForegroundColor Yellow
}

Function Simulate-LogClearing {
    Write-Host "[*] Simulating Log Clearing..." -ForegroundColor Cyan
    wevtutil cl Application
    Write-Host "[+] Expected Alert: Rule 100170/100171" -ForegroundColor Yellow
}

Function Cleanup-All {
    Write-Host "[*] Cleaning up all persistence mechanisms..." -ForegroundColor Cyan
    schtasks /delete /tn "BenignImplant" /f 2>$null
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "BenignImplant" -ErrorAction SilentlyContinue
    Remove-Item "C:\Users\Public\implant.ps1" -ErrorAction SilentlyContinue
    Remove-Item "C:\Users\Public\implant.log" -ErrorAction SilentlyContinue
    Remove-Item "C:\Users\Public\README.txt" -ErrorAction SilentlyContinue
    certutil -urlcache * delete
    Write-Host "[+] Cleanup Complete" -ForegroundColor Green
}

do {
    Write-Host "=============================" -ForegroundColor Magenta
    Write-Host " Persistence Simulator Menu" -ForegroundColor White
    Write-Host "=============================" -ForegroundColor Magenta
    Write-Host "1. Create Scheduled Task (Rule 100150)"
    Write-Host "2. Create Registry Run Key (Rule 100160)"
    Write-Host "3. Simulate Certutil Download (Rule 100140)"
    Write-Host "4. Execute Encoded PowerShell (Rule 100130)"
    Write-Host "5. Simulate Log Clearing (Rule 100170/100171)"
    Write-Host "6. Run All Tests"
    Write-Host "7. Cleanup All"
    Write-Host "8. Exit"
    $choice = Read-Host "Select an option"
    
    switch ($choice) {
        '1' { Create-ScheduledTaskPersistence }
        '2' { Create-RegistryRunKey }
        '3' { Simulate-CertutilDownload }
        '4' { Execute-EncodedPowerShell }
        '5' { Simulate-LogClearing }
        '6' { 
            Create-ScheduledTaskPersistence
            Create-RegistryRunKey
            Simulate-CertutilDownload
            Execute-EncodedPowerShell
            Simulate-LogClearing
        }
        '7' { Cleanup-All }
        '8' { break }
    }
} while ($choice -ne '8')
