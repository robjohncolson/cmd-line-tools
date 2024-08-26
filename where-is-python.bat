@echo off
setlocal enabledelayedexpansion

:: Check if Python is already in PATH
where python >nul 2>nul
if %errorlevel% equ 0 (
    echo Python is already in PATH
    exit /b 0
)

:: List of common installation directories
set "dirs=C:\Python39 C:\Python38 C:\Python37 C:\Python36 C:\Python35 C:\Program Files\Python39 C:\Program Files\Python38 C:\Program Files\Python37 C:\Program Files\Python36 C:\Program Files\Python35 C:\Users\%USERNAME%\AppData\Local\Programs\Python"

:: Search for python.exe
echo Searching common directories for Python...
set "counter=0"
set "total_dirs=0"
for %%d in (%dirs%) do set /a "total_dirs+=1"

for %%d in (%dirs%) do (
    set /a "counter+=1"
    echo Checking [!counter!/%total_dirs%]: %%d
    if exist "%%d\python.exe" (
        set "PYTHON_PATH=%%d"
        echo Python found!
        goto :found
    )
)

echo Python not found in common directories.

:: If not found in common directories, search entire C drive
echo Searching entire C drive for Python. This may take a while...
set "drive_counter=0"
set "total_drive_dirs=0"
set "last_progress=0"
for /f %%i in ('dir C:\ /ad /b /s ^| find /c /v ""') do (
    set "total_drive_dirs=%%i"
    echo Counting directories: !total_drive_dirs!
)

echo Total directories to search: %total_drive_dirs%
echo.
echo Progress:
echo [--------------------]
echo  0%%   25%%   50%%   75%%  100%%

for /f "delims=" %%i in ('where /r C:\ python.exe 2^>nul') do (
    set /a "drive_counter+=1"
    set /a "progress=drive_counter*100/total_drive_dirs"
    if !progress! gtr !last_progress! (
        set /a "bar_length=progress/5"
        set "progress_bar="
        for /l %%j in (1,1,!bar_length!) do set "progress_bar=!progress_bar!#"
        for /l %%j in (!bar_length!,1,20) do set "progress_bar=!progress_bar!-"
        echo [!progress_bar!] !progress!%%
        echo Checking: %%~dpi
        set "last_progress=!progress!"
    )
    set "PYTHON_PATH=%%~dpi"
    if exist "%%~dpi\python.exe" (
        echo.
        echo Python found!
        goto :found
    )
)
echo Search complete.

echo Python not found on C drive.
goto :not_found

:found
echo Python located at: %PYTHON_PATH%

:: Add to PATH
setx PATH "%PATH%;!PYTHON_PATH!" /M
echo Python added to PATH

:: Verify
echo Verifying Python in PATH:
where python

:not_found
exit /b 1

endlocal