@echo off
title OOBE HWID Capture

powershell -NoProfile -ExecutionPolicy Bypass -File "D:\Scripts\UpdatedGetHash.ps1"

echo. 
set /p dummy="Press ENTER to Acknowledge capture.."
set /p dummy="Press Enter again to immediately shut down..."

shutdown /s /t 00
