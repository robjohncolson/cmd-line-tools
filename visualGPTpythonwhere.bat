@echo off
setlocal enabledelayedexpansion

:: Check if USERNAME is set, if not, prompt the user
if "%USERNAME%"=="" (
    set /p USERNAME="USERNAME not set. Please enter your username: "
) else (
    echo Using current username: %USERNAME%
    choice /C YN /M "Is this correct? (Y/N)"
    if errorlevel 2 (
        set /p USERNAME="Please enter the correct username: "
    )
)

echo Searching for Python installations for user: %USERNAME%

:: Check if Python is already in PATH
where python >nul 2>nul
if %errorlevel% equ 0 (
    echo Python is already in PATH.
    exit /b 0
)

set "dirs=C:\Python C:\Python39 C:\Python38 C:\Python37 C:\Python36 C:\Python35 "
set "dirs=!dirs!C:\Program Files\Python C:\Program Files\Python39 C:\Program Files\Python38 "
set "dirs=!dirs!C:\Program Files\Python37 C:\Program Files\Python36 C:\Program Files\Python35 "
set "dirs=!dirs!C:\Program Files (x86)\Python C:\Program Files (x86)\Python39 "
set "dirs=!dirs!C:\Program Files (x86)\Python38 C:\Program Files (x86)\Python37 "
set "dirs=!dirs!C:\Program Files (x86)\Python36 C:\Program Files (x86)\Python35 "
set "dirs=!dirs!C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python39 "
set "dirs=!dirs!C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python38 "
set "dirs=!dirs!C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python37 "
set "dirs=!dirs!C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python36 "
set "dirs=!dirs!C:\Users\%USERNAME%\AppData\Local\Microsoft\WindowsApps "
set "dirs=!dirs!C:\Users\%USERNAME%\AppData\Local\Programs\Python\Launcher"

:: Add more recent Python versions and a wildcard search
set "dirs=!dirs!C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python3* "
set "dirs=!dirs!C:\Program Files\Python3* C:\Program Files (x86)\Python3* "

echo Searching common directories for Python...
for %%d in (!dirs!) do (
    if exist "%%d\python.exe" (
        set "PYTHON_PATH=%%d"
        echo Potential Python found in %%d
        
        :: Verify it's a real Python installation
        "%%d\python.exe" --version >nul 2>&1
        if !errorlevel! equ 0 (
            echo Confirmed Python installation in %%d
            goto :found
        ) else (
            echo Not a valid Python installation, continuing search...
        )
    )
)

echo Python not found in common directories.
echo Searching entire C drive for Python. This may take a while...

for /f "delims=" %%i in ('where /r C:\ python.exe 2^>nul') do (
    set "PYTHON_PATH=%%~dpi"
    "%%i" --version >nul 2>&1
    if !errorlevel! equ 0 (
        echo Confirmed Python installation in %%~dpi
        goto :found
    )
)

echo Python not found on C drive.
goto :not_found

:found
echo Python located at: %PYTHON_PATH%

:: Add to PATH using PowerShell to avoid truncation
powershell -Command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';%PYTHON_PATH%', 'Machine')"
echo Python added to PATH.

:: Verify using PowerShell
echo Verifying Python in PATH:
powershell -Command "& {$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine'); python --version}"
if !errorlevel! equ 0 (
    echo Python successfully added to PATH.
) else (
    echo Failed to add Python to PATH.
)
goto :end

:not_found
echo Python could not be found on this system.
exit /b 1

:end
endlocal
exit /b 0