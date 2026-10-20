@echo off
title OOBE HWID Capture

echo Searching for UpdatedGetHash.ps1...
echo.

set "SCRIPT="

for %%D in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%D:\Scripts\UpdatedGetHash.ps1" (
        set "SCRIPT=%%D:\Scripts\UpdatedGetHash.ps1"
        goto FOUND
    )
)

echo ERROR: UpdatedGetHash.ps1 was not found on any drive.
echo.
pause
exit /b 1

:FOUND
echo Found:
echo %SCRIPT%
echo.
echo Starting hardware hash capture...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"

echo.
set /p dummy="Press ENTER to Acknowledge capture.."
set /p dummy="Press Enter again to immediately shut down..."

shutdown /s /t 00