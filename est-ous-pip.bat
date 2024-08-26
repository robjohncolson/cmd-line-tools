@echo off
setlocal

set PYTHON_VERSION=Python39
set USERNAME=ColsonR

echo Searching for pip...

REM Check global installation location
if exist "C:\Users\%USERNAME%\AppData\Local\Programs\Python\%PYTHON_VERSION%\Scripts\pip.exe" (
    echo Found pip in global installation:
    echo C:\Users\%USERNAME%\AppData\Local\Programs\Python\%PYTHON_VERSION%\Scripts\pip.exe
) else (
    echo Pip not found in global installation.
)

REM Check user installation location
if exist "C:\Users\%USERNAME%\AppData\Roaming\Python\%PYTHON_VERSION%\Scripts\pip.exe" (
    echo Found pip in user installation:
    echo C:\Users\%USERNAME%\AppData\Roaming\Python\%PYTHON_VERSION%\Scripts\pip.exe
) else (
    echo Pip not found in user installation.
)

REM Check if pip is installed in any virtual environments in a specified folder
REM Adjust the path below to your virtual environment directory if needed
set VENV_PATH=C:\path\to\your\venv

if exist "%VENV_PATH%\Scripts\pip.exe" (
    echo Found pip in virtual environment:
    echo %VENV_PATH%\Scripts\pip.exe
) else (
    echo Pip not found in virtual environment.
)

echo Search complete.
endlocal
pause
