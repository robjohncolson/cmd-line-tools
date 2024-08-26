@echo off
setlocal enabledelayedexpansion

:: Confirm username
echo Current username: %USERNAME%
set /p confirm="Is this correct? (Y/N): "
if /i "%confirm%" neq "Y" (
    set /p USERNAME="Enter correct username: "
)



echo Searching common locations...
REM Search for Git installation in common locations
set "PYTHON_PATH="
for %%I in (
    "C:\Python312\python.exe"
    "C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python312\python.exe"
    "C:\Program Files\Python312\python.exe"
    "C:\Program Files (x86)\Python312\python.exe"
    ) do (
    if exist "%%~I" (
        set "PYTHON_PATH=%%~dpI"
        echo Python found: %%~dpI
        goto :found
    )
)



echo Python not found in common locations. Searching entire C drive...

:: Bisection search
set "total_files=0"
for /f %%A in ('dir /s /b /a-d C:\ ^| find /c /v ""') do set total_files=%%A

set "current=0"
for /f "delims=" %%F in ('dir /s /b /a-d C:\') do (
    set /a "current+=1"
    set /a "progress=(current*100)/total_files"
    if "%%~nxF"=="python.exe" (
        echo Python found: %%F
        goto :found
    )
    set /a "progress_mod=progress %% 5"
    if !progress_mod! equ 0 (
        echo !progress!%% searched...
    )
)

echo Python not found.
goto :eof

:found
echo Copy-paste the following line into your terminal:
echo $env:PATH += ";%PYTHON_PATH%" | clip