# ================================
# AUTOPILOT HASH COLLECTION (OOBE SAFE)
# ================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "===============================" -ForegroundColor Green
Write-Host " AUTOPILOT HASH TOOL (OOBE SAFE)" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

# -------------------------------
# FIND USB DRIVE
# -------------------------------
$usb = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Select-Object -First 1

if (-not $usb) {
    Write-Host "❌ USB DRIVE NOT FOUND" -ForegroundColor Red
    pause
    exit
}

$usbPath = $usb.DeviceID
Write-Host "USB FOUND AT: $usbPath" -ForegroundColor Green

# -------------------------------
# DEVICE INFO (OPTIONAL DISPLAY)
# -------------------------------
$cs = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS

Write-Host ""
Write-Host "===== DEVICE INFO =====" -ForegroundColor Cyan
Write-Host "Manufacturer : $($cs.Manufacturer)" -ForegroundColor Green
Write-Host "Model        : $($cs.Model)" -ForegroundColor Green
Write-Host "Serial       : $($bios.SerialNumber)" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Cyan
Write-Host ""

# -------------------------------
# PREP OUTPUT PATH
# -------------------------------
$outputFile = "$usbPath\Autopilot_Hash.csv"

# Remove old file if exists (prevents Zytech rejection)
if (Test-Path $outputFile) {
    Remove-Item $outputFile -Force
}

# -------------------------------
# ENSURE SCRIPT IS AVAILABLE LOCALLY
# -------------------------------
$scriptPath = "$env:TEMP\Get-WindowsAutopilotInfo.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Host "Downloading Autopilot script..." -ForegroundColor Yellow

    Invoke-WebRequest `
        -Uri "https://raw.githubusercontent.com/microsoft/WindowsAutopilotIntune/master/Get-WindowsAutopilotInfo.ps1" `
        -OutFile $scriptPath
}

# -------------------------------
# RUN AUTOPILOT CAPTURE (IMPORTANT FIX)
# -------------------------------
Write-Host "Collecting Autopilot Hardware Hash..." -ForegroundColor Yellow

powershell.exe -ExecutionPolicy Bypass -File $scriptPath -OutputFile $outputFile

# -------------------------------
# VERIFY OUTPUT
# -------------------------------
if (Test-Path $outputFile) {
    $size = (Get-Item $outputFile).Length

    if ($size -lt 500) {
        Write-Host "❌ WARNING: HASH FILE LOOKS TOO SMALL (LIKELY INVALID)" -ForegroundColor Red
    } else {
        Write-Host "✅ Autopilot hash successfully generated" -ForegroundColor Green
        Write-Host "Saved to: $outputFile" -ForegroundColor Green
    }
} else {
    Write-Host "❌ FAILED: No output file created" -ForegroundColor Red
}

# -------------------------------
# SHUTDOWN
# -------------------------------
Write-Host ""
Write-Host "Shutting down in 5 seconds..." -ForegroundColor Green
Start-Sleep 5
shutdown /s /t 0