@echo off
setlocal enabledelayedexpansion

:: Check if Python is already in PATH
where python >nul 2>nul
if %errorlevel% equ 0 (
    echo Python is already in PATH.
    exit /b 0
)

:: List of common installation directories
set "dirs=C:\Python39 C:\Python38 C:\Python37 C:\Python36 C:\Python35 C:\Program Files\Python39 C:\Program Files\Python38 C:\Program Files\Python37 C:\Program Files\Python36 C:\Program Files\Python35 C:\Users\%USERNAME%\AppData\Local\Programs\Python"

:: Search for python.exe in common directories
echo Searching common directories for Python...
set "counter=0"
for %%d in (%dirs%) do set /a "total_dirs+=1"

for %%d in (%dirs%) do (
    set /a "counter+=1"
    set /a "progress=(counter*100)/total_dirs"
    echo [%%counter%%/%total_dirs% - !progress!%%] Checking: %%d
    if exist "%%d\python.exe" (
        set "PYTHON_PATH=%%d"
        echo Python found in %%d
        goto :found
    )
)

:: If not found in common directories, search entire C drive
echo Python not found in common directories.
echo Searching entire C drive for Python. This may take a while...

set "drive_counter=0"
for /f %%i in ('dir C:\ /ad /b /s ^| find /c /v ""') do set "total_drive_dirs=%%i"

echo Total directories to search: %total_drive_dirs%
echo.
echo Progress:
echo [--------------------]
echo  0%%   25%%   50%%   75%%  100%%

for /f "delims=" %%i in ('where /r C:\ python.exe 2^>nul') do (
    set /a "drive_counter+=1"
    set /a "progress=(drive_counter*100)/total_drive_dirs"
    set /a "bar_length=progress/5"
    set "progress_bar="
    for /l %%j in (1,1,!bar_length!) do set "progress_bar=!progress_bar!#"
    for /l %%j in (!bar_length!,1,20) do set "progress_bar=!progress_bar!-"
    echo [!progress_bar!] !progress!%% Checking: %%~dpi

    set "PYTHON_PATH=%%~dpi"
    if exist "%%~dpi\python.exe" (
        echo Python found in %%~dpi
        goto :found
    )
)

echo Python not found on C drive.
goto :not_found

:found
echo Python located at: %PYTHON_PATH%

:: Add to PATH
setx PATH "%PATH%;%PYTHON_PATH%" /M
echo Python added to PATH.

:: Verify
echo Verifying Python in PATH:
where python
if %errorlevel% equ 0 (
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
