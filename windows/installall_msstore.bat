@echo off
REM Batch script for Windows with Microsoft Store Python support
setlocal enabledelayedexpansion

echo === Lint Heroes Installation (Microsoft Store Python) ===
echo This script is optimized for Microsoft Store Python installations

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found. Please install Python from python.org or Microsoft Store
    pause
    exit /b 1
)

echo ✔ Using Python at:
where python

REM Check if it's Microsoft Store Python
where python | findstr /i "WindowsApps" >nul
if %errorlevel% equ 0 (
    echo ⚠ Microsoft Store Python detected
    echo   This may cause some compatibility issues
    echo   Consider installing Python from python.org for better compatibility
)

REM Get Python version using sys module (most reliable for MS Store Python)
for /f %%i in ('python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2^>nul') do set PY_VERSION=%%i

if "%PY_VERSION%"=="" (
    echo ❌ Cannot determine Python version
    echo   Try running: python --version
    pause
    exit /b 1
)

echo ✔ Detected Python version: %PY_VERSION%

REM Check if version is 3.9+ (minimum requirement)
python -c "import sys; exit(0 if sys.version_info >= (3, 9) else 1)" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python %PY_VERSION% is too old. Python 3.9+ is required.
    echo   Detected version: %PY_VERSION%
    echo   Required: 3.9 or higher
    pause
    exit /b 1
)

echo ✔ Python version %PY_VERSION% is compatible

echo ▶ Creating virtualenv .venv (if missing)...
if not exist ".venv" (
    python -m venv .venv
    if %errorlevel% neq 0 (
        echo ❌ Failed to create virtual environment
        echo   Try running: python -m venv .venv
        pause
        exit /b 1
    )
    echo ✔ Virtual environment created
)

echo ▶ Activating virtual environment...
call .venv\Scripts\activate.bat

echo ▶ Installing linting tools...
if exist "req.txt" (
    pip install -r req.txt
) else (
    echo Installing individual tools...
    pip install pylint flake8 bandit mypy isort
)

if %errorlevel% neq 0 (
    echo ❌ Failed to install tools from requirements
    echo   Try running: pip install -r req.txt
    pause
    exit /b 1
)

echo ▶ Installing pyright (fast type checker)...
pip install pyright
if %errorlevel% neq 0 (
    echo ⚠ Failed to install pyright via pip
    echo   You can install it manually: pip install pyright
    echo   Or download from: https://github.com/microsoft/pyright/releases
)

echo ✔ All tools installed successfully

echo ▶ Setting up aliases...
REM Create batch files in user's bin directory
set ALIAS_DIR=%USERPROFILE%\bin
if not exist "%ALIAS_DIR%" mkdir "%ALIAS_DIR%"

REM Add to PATH if not already there
echo %PATH% | findstr /i "%ALIAS_DIR%" >nul
if %errorlevel% neq 0 (
    setx PATH "%PATH%;%ALIAS_DIR%" >nul 2>&1
    echo ✔ Added %ALIAS_DIR% to PATH
)

REM Create lint-heroes.bat
echo @echo off > "%ALIAS_DIR%\lint-heroes.bat"
echo cd /d "%~dp0" >> "%ALIAS_DIR%\lint-heroes.bat"
echo call "%~dp0\windows\lint_all.bat" %%* >> "%ALIAS_DIR%\lint-heroes.bat"

REM Create lint-install.bat
echo @echo off > "%ALIAS_DIR%\lint-install.bat"
echo cd /d "%~dp0" >> "%ALIAS_DIR%\lint-install.bat"
echo call "%~dp0\windows\installall_msstore.bat" >> "%ALIAS_DIR%\lint-install.bat"

REM Create lint-install-multiple.bat
echo @echo off > "%ALIAS_DIR%\lint-install-multiple.bat"
echo cd /d "%~dp0" >> "%ALIAS_DIR%\lint-install-multiple.bat"
echo powershell -ExecutionPolicy Bypass -File "%~dp0\windows\install_multiple.ps1" %%* >> "%ALIAS_DIR%\lint-install-multiple.bat"

REM Create lint.bat (shortcut)
echo @echo off > "%ALIAS_DIR%\lint.bat"
echo call "%~dp0\lint-heroes.bat" %%* >> "%ALIAS_DIR%\lint.bat"

REM Create lint-multi.bat (shortcut)
echo @echo off > "%ALIAS_DIR%\lint-multi.bat"
echo call "%~dp0\lint-install-multiple.bat" %%* >> "%ALIAS_DIR%\lint-multi.bat"

echo ✔ Batch aliases created in %ALIAS_DIR%
echo   Available commands:
echo   - lint-heroes: run linting
echo   - lint-install: reinstall linters
echo   - lint-install-multiple: install for multiple Python versions
echo   - lint: shortcut for lint-heroes
echo   - lint-multi: shortcut for lint-install-multiple

echo.
echo === Installation Complete ===
echo You can now use:
echo   lint-heroes your_file.py
echo   lint-heroes src/
echo   lint-heroes
echo.
echo Note: If you encounter issues with Microsoft Store Python,
echo consider installing Python from python.org for better compatibility.
echo.
pause
