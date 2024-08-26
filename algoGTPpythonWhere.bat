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
echo Python not in PATH

:: Enhanced list of common installation directories
set "dirs="
echo dirs set

:: Create directory list without nested loops
call :add_dir "C:\Python"
call :add_dir "C:\Program Files\Python"
call :add_dir "C:\Program Files (x86)\Python"
call :add_dir "C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python"

:: Add specific version numbers
for %%v in (31 32 33 34 35 36 37 38 39 310 311 312 313 314 315 316 317 318 319) do (
    call :add_dir "C:\Python%%v"
    call :add_dir "C:\Program Files\Python%%v"
    call :add_dir "C:\Program Files (x86)\Python%%v"
    call :add_dir "C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python%%v"
)

:: Add wildcard for future Python versions
call :add_dir "C:\Python3*"
call :add_dir "C:\Program Files\Python3*"
call :add_dir "C:\Program Files (x86)\Python3*"
call :add_dir "C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python3*"

goto :end_add_dir

:add_dir
set "dirs=!dirs!%~1;"
goto :eof

:end_add_dir
echo List of common directories have been set.

:: Add specific directories
set "dirs=!dirs!C:\Users\%USERNAME%\AppData\Local\Microsoft\WindowsApps;"
set "dirs=!dirs!C:\Users\%USERNAME%\AppData\Local\Programs\Python\Launcher;"

echo Specific directories have been added.

:: Iterate directly over the directories
for %%d in (%dirs%) do (
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
echo directories searched

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
