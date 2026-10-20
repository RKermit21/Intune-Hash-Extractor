$ErrorActionPreference = "Stop"

# ============================================================
# WINDOWS AUTOPILOT HWID CAPTURE
# ============================================================
# USB structure:
#
# USB\
# ├── 1.bat
# └── Scripts\
#     ├── UpdatedGetHash.ps1
#     └── Get-WindowsAutoPilotInfo.ps1
#
# This script does NOT use a hard-coded USB drive letter.
# ============================================================

# Find the folder where THIS script is located
$scriptFolder = $PSScriptRoot

# Find Microsoft's Autopilot script in the same folder
$autopilotScript = Join-Path $scriptFolder "Get-WindowsAutoPilotInfo.ps1"

# Temporary HWID CSV on the Windows computer
$outputCsv = "C:\HWID.csv"


# ============================================================
# START
# ============================================================

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "     WINDOWS AUTOPILOT HWID CAPTURE" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[INFO] Current script location:" -ForegroundColor Cyan
Write-Host $scriptFolder -ForegroundColor Yellow
Write-Host ""

Write-Host "[INFO] Looking for Autopilot script:" -ForegroundColor Cyan
Write-Host $autopilotScript -ForegroundColor Yellow
Write-Host ""


# ============================================================
# CHECK FOR MICROSOFT AUTOPILOT SCRIPT
# ============================================================

if (!(Test-Path -LiteralPath $autopilotScript)) {

    Write-Host "=========================================" -ForegroundColor Red
    Write-Host "[ERROR] Autopilot script not found!" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host ""

    Write-Host "Expected file:" -ForegroundColor Yellow
    Write-Host $autopilotScript -ForegroundColor Yellow
    Write-Host ""

    Write-Host "Make sure Get-WindowsAutoPilotInfo.ps1 is in the same" -ForegroundColor Yellow
    Write-Host "Scripts folder as UpdatedGetHash.ps1." -ForegroundColor Yellow
    Write-Host ""

    pause
    exit 1
}


Write-Host "[SUCCESS] Autopilot script found." -ForegroundColor Green
Write-Host ""


# ============================================================
# CAPTURE AUTOPILOT HARDWARE HASH
# ============================================================

Write-Host "[INFO] Capturing Windows Autopilot hardware information..." -ForegroundColor Cyan
Write-Host ""

& $autopilotScript -OutputFile $outputCsv


# ============================================================
# CHECK THAT HWID CSV WAS CREATED
# ============================================================

if (!(Test-Path -LiteralPath $outputCsv)) {

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host "[ERROR] HWID.csv was not created." -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host ""

    pause
    exit 1
}


Write-Host ""
Write-Host "[SUCCESS] HWID.csv was created." -ForegroundColor Green
Write-Host ""


# ============================================================
# READ HWID CSV
# ============================================================

$csv = Import-Csv -LiteralPath $outputCsv

if (!$csv) {

    Write-Host ""
    Write-Host "[ERROR] HWID.csv is empty." -ForegroundColor Red
    Write-Host ""

    pause
    exit 1
}

$device = $csv[0]

$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$serial = $device.'Device Serial Number'

$hash = $device.'Hardware Hash'


# ============================================================
# VERIFY HARDWARE HASH
# ============================================================

if ([string]::IsNullOrWhiteSpace($hash)) {

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host "[ERROR] Hardware Hash was not returned." -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host ""

    Write-Host "Serial Number:" -ForegroundColor Yellow
    Write-Host $serial -ForegroundColor White
    Write-Host ""

    pause
    exit 1
}


# ============================================================
# SAVE MASTER CSV TO USB
# ============================================================

# Because $scriptFolder points to the USB, this automatically
# saves to the correct USB drive regardless of whether it is
# D:, E:, F:, G:, etc.

$masterCsv = Join-Path $scriptFolder "HWID_Master.csv"


# ============================================================
# CREATE MASTER CSV IF IT DOES NOT EXIST
# ============================================================

if (!(Test-Path -LiteralPath $masterCsv)) {

    "Timestamp,Serial,HardwareHash" |
        Out-File -LiteralPath $masterCsv -Encoding ASCII
}


# ============================================================
# ADD DEVICE TO MASTER CSV
# ============================================================

"$time,$serial,$hash" |
    Out-File -LiteralPath $masterCsv -Append -Encoding ASCII


# ============================================================
# SUCCESS
# ============================================================

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "        CAPTURE SUCCESSFUL" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Serial Number:" -ForegroundColor Cyan
Write-Host $serial -ForegroundColor White

Write-Host ""

Write-Host "Hardware Hash captured successfully." -ForegroundColor Green

Write-Host ""

Write-Host "Saved master CSV to:" -ForegroundColor Cyan
Write-Host $masterCsv -ForegroundColor White

Write-Host ""

Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

pause