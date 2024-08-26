@echo off
setlocal

:: Confirm username
echo Current username: %USERNAME%
set /p confirm="Is this correct? (Y/N): "
if /i "%confirm%" neq "Y" (
    set /p USERNAME="Enter correct username: "
)


REM find path to cmd-line-tools
set "cmd-line-tools="
for /f "delims=" %%i in ('dir /s /b /ad "%USERPROFILE%\cmd-line-tools" 2^>nul') do (
    if not defined cmd-line-tools (
        set "cmd-line-tools=%%~dpi"
        echo cmd-line-tools folder found at: %%~dpi
        echo File: %%~nxi
        echo Path: %%~dpi
        echo File+Path: %%i
    )
)

if not defined cmd-line-tools (
    echo cmd-line-tools folder not found in user's directory.
)

echo $env:PATH += ";%cmd-line-tools%" | clip

endlocal

