@echo off
setlocal

:: Confirm username
::echo Current username: %USERNAME%
::set /p confirm="Is this correct? (Y/N): "
::if /i "%confirm%" neq "Y" (
::    set /p USERNAME="Enter correct username: "
::)


REM find path to cmd-line-tools

set "cmd-line-tools="
for /f "delims=" %%i in ('dir /s /b /ad "%USERPROFILE%\cmd-line-tools" 2^>nul') do (
    if not defined cmd-line-tools (
        set "cmd-line-tools=%%~dpi"
        REM echo cmd-line-tools folder found at: %%~dpi
        REM echo File: %%~nxi
        REM echo Path: %%~dpi
        REM echo File+Path: %%i
    )
)

if not defined cmd-line-tools (
    echo cmd-line-tools folder not found in user's directory.
)

echo $env:PATH += ";%cmd-line-tools%" | clip
echo function home { Set-Location -Path '%cmd-line-tools%' }
REM powershell -Command "function home { Set-Location -Path '%cmd-line-tools%' }"
REM powershell -Command "$env:PATH += ';%cmd-line-tools%'"
    

if defined cmd-line-tools (
    echo Contents of cmd-line-tools directory:
    for /f "delims=" %%a in ('dir /b "%cmd-line-tools%"') do (
        echo %%a
    )
) else (
    echo cmd-line-tools directory not found or path not set.
)
endlocal

