<#
.SYNOPSIS
    Automates Atomic Red Team test execution for the SIEM Home Lab.
.DESCRIPTION
    This script installs Invoke-AtomicRedTeam if not present, downloads the AtomicsFolder,
    and runs a defined set of atomic tests to validate Wazuh detections.
.NOTES
    WARNING: Only run this script in an isolated lab environment.
#>

Write-Host "WARNING: Only run this script in an isolated lab environment." -ForegroundColor Red
Start-Sleep -Seconds 3

# Prerequisites check
if (-not (Get-Module -ListAvailable -Name Invoke-AtomicRedTeam)) {
    Write-Host "[*] Installing Invoke-AtomicRedTeam..." -ForegroundColor Cyan
    IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
    Install-AtomicRedTeam -getAtomics
} else {
    Write-Host "[+] Invoke-AtomicRedTeam is already installed." -ForegroundColor Green
}

$tests = @(
    @{ TechniqueId = "T1059.001"; TestNumber = 1; Description = "PowerShell Encoded Command"; ExpectedRule = "100130" },
    @{ TechniqueId = "T1053.005"; TestNumber = 1; Description = "Scheduled Task"; ExpectedRule = "100150" },
    @{ TechniqueId = "T1547.001"; TestNumber = 1; Description = "Registry Run Key"; ExpectedRule = "100160" },
    @{ TechniqueId = "T1548.002"; TestNumber = 1; Description = "UAC Bypass"; ExpectedRule = "Unknown" },
    @{ TechniqueId = "T1003.001"; TestNumber = 1; Description = "LSASS Access (procdump)"; ExpectedRule = "Unknown" },
    @{ TechniqueId = "T1070.001"; TestNumber = 1; Description = "Clear Event Logs"; ExpectedRule = "100170/100171" },
    @{ TechniqueId = "T1105"; TestNumber = 1; Description = "Certutil Download"; ExpectedRule = "100140" }
)

foreach ($test in $tests) {
    Write-Host "=======================================================" -ForegroundColor Magenta
    Write-Host "Running $($test.TechniqueId) Test $($test.TestNumber) : $($test.Description)" -ForegroundColor Cyan
    Write-Host "Expected Wazuh Rule: $($test.ExpectedRule)" -ForegroundColor Yellow
    Write-Host "=======================================================" -ForegroundColor Magenta
    
    try {
        Invoke-AtomicTest $test.TechniqueId -TestNumbers $test.TestNumber -CheckPrereqs
        Invoke-AtomicTest $test.TechniqueId -TestNumbers $test.TestNumber -GetPrereqs
        Invoke-AtomicTest $test.TechniqueId -TestNumbers $test.TestNumber
        
        Write-Host "[*] Waiting 30 seconds for Wazuh to process..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        Read-Host "Please verify alert in Wazuh Dashboard. Press Enter to continue and cleanup..."
        
        Invoke-AtomicTest $test.TechniqueId -TestNumbers $test.TestNumber -Cleanup
    } catch {
        Write-Host "[-] Error executing test: $_" -ForegroundColor Red
    }
}

Write-Host "[+] All atomic tests completed." -ForegroundColor Green
