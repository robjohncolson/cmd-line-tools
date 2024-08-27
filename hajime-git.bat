@echo off
setlocal

:: Confirm username
echo Current username: %USERNAME%
set /p confirm="Is this correct? (Y/N): "
if /i "%confirm%" neq "Y" (
    set /p USERNAME="Enter correct username: "
)


REM Search for Git installation in common locations
set "gitpath="
for %%I in (
    "C:\Program Files\Git\bin\git.exe"
    "C:\Program Files (x86)\Git\bin\git.exe"
    "C:\Users\%username%\AppData\Local\Programs\Git\bin\git.exe"
    "C:\Program Files\Git\cmd\git.exe"
    "C:\Program Files (x86)\Git\cmd\git.exe"
    "C:\Users\%username%\AppData\Local\Programs\Git\cmd\git.exe"
    "C:\ProgramData\Git\bin\git.exe"
    "D:\Programs\Git\bin\git.exe"
    "D:\Programs\Git\cmd\git.exe"
    ) do (
    if exist "%%~I" (
        set "gitpath=%%~dpI"
        goto :found
    )
)

:found
if defined gitpath (
    REM Add Git path to the system PATH variable for current session
    set "PATH=%PATH%;%gitpath%"

    REM Persist the change for future sessions
    setx PATH "%PATH%"
    echo Git found at %gitpath% and added to PATH.
) else (
    echo Git not found on this system.
)   

echo $env:PATH += ";%gitpath%" | clip
echo function home { Set-Location -Path '%cmd-line-tools%' }
endlocal

