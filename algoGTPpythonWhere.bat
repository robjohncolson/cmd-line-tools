@echo off
setlocal enabledelayedexpansion

:: Confirm username
echo Current username: %USERNAME%
set /p confirm="Is this correct? (Y/N): "
if /i "%confirm%" neq "Y" (
    set /p USERNAME="Enter correct username: "
)

:: Common locations
set "common_dirs=C:\Python312 C:\Program Files\Python312 C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python312"

echo Searching common locations...
for %%d in (%common_dirs%) do (
    if exist "%%d\python.exe" (
        echo Python found: %%d\python.exe
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
echo Python location: %PYTHON_PATH%

echo $env:PATH += ";%PYTHON_PATH%"