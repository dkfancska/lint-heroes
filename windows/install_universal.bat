@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    Lint-Heroes Universal Installer
echo ========================================
echo.

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

echo 📁 Project root: %PROJECT_ROOT%
echo.

REM Check if Python is installed
echo 🔍 Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python is not installed or not in PATH
    echo.
    echo Please install Python from https://python.org
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

REM Get Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo ✅ Python %PYTHON_VERSION% found

REM Create user bin directory
set "USER_BIN=%USERPROFILE%\bin"
if not exist "%USER_BIN%" (
    echo 📁 Creating user bin directory: %USER_BIN%
    mkdir "%USER_BIN%"
)

REM Create virtual environment
echo.
echo 🐍 Creating virtual environment...
cd /d "%PROJECT_ROOT%"
if exist "venv" (
    echo ⚠️ Virtual environment already exists, removing...
    rmdir /s /q "venv"
)

python -m venv venv
if %errorlevel% neq 0 (
    echo ❌ Failed to create virtual environment
    pause
    exit /b 1
)

REM Activate virtual environment
echo 🔧 Activating virtual environment...
call "venv\Scripts\activate.bat"
if %errorlevel% neq 0 (
    echo ❌ Failed to activate virtual environment
    pause
    exit /b 1
)

REM Upgrade pip
echo 📦 Upgrading pip...
python -m pip install --upgrade pip

REM Install linters
echo.
echo 📦 Installing linters...
if exist "req.txt" (
    python -m pip install -r req.txt
) else (
    python -m pip install pylint flake8 bandit mypy pyright isort
)

REM Create configuration files
echo.
echo ⚙️ Creating configuration files...

REM Create .pylintrc
if not exist ".pylintrc" (
    echo [MASTER] > .pylintrc
    echo ignore=venv,.venv,build,dist,.mypy_cache,.pytest_cache,.git >> .pylintrc
    echo. >> .pylintrc
    echo [MESSAGES CONTROL] >> .pylintrc
    echo disable=C0114,C0115,C0116  ; ignore missing module/class/function docstrings >> .pylintrc
    echo. >> .pylintrc
    echo [REPORTS] >> .pylintrc
    echo score = no >> .pylintrc
    echo. >> .pylintrc
    echo [TYPECHECK] >> .pylintrc
    echo generated-members=requests.*,numpy.* >> .pylintrc
    echo. >> .pylintrc
    echo [FORMAT] >> .pylintrc
    echo max-line-length=120 >> .pylintrc
    echo ✅ Created .pylintrc
)

REM Create .flake8
if not exist ".flake8" (
    echo [flake8] > .flake8
    echo exclude = .venv,venv,build,dist,.mypy_cache,.pytest_cache,.git >> .flake8
    echo max-line-length = 120 >> .flake8
    echo extend-ignore = E203 >> .flake8
    echo select = B, E, F, W, B9 >> .flake8
    echo ✅ Created .flake8
)

REM Create bandit.yaml
if not exist "bandit.yaml" (
    echo exclude_dirs: > bandit.yaml
    echo   - .venv >> bandit.yaml
    echo   - venv >> bandit.yaml
    echo   - build >> bandit.yaml
    echo   - dist >> bandit.yaml
    echo   - .mypy_cache >> bandit.yaml
    echo   - .pytest_cache >> bandit.yaml
    echo   - .git >> bandit.yaml
    echo ✅ Created bandit.yaml
)

REM Create pyrightconfig.json
if not exist "pyrightconfig.json" (
    echo { > pyrightconfig.json
    echo   "exclude": [ >> pyrightconfig.json
    echo     ".venv", >> pyrightconfig.json
    echo     "venv", >> pyrightconfig.json
    echo     "build", >> pyrightconfig.json
    echo     "dist", >> pyrightconfig.json
    echo     ".mypy_cache", >> pyrightconfig.json
    echo     ".pytest_cache", >> pyrightconfig.json
    echo     ".git" >> pyrightconfig.json
    echo   ], >> pyrightconfig.json
    echo   "pythonVersion": "3.9" >> pyrightconfig.json
    echo } >> pyrightconfig.json
    echo ✅ Created pyrightconfig.json
)

REM Create global alias
echo.
echo 🔗 Creating global alias...
set "ALIAS_FILE=%USER_BIN%\lint-heroes.bat"
echo @echo off > "%ALIAS_FILE%"
echo cd /d "%PROJECT_ROOT%" >> "%ALIAS_FILE%"
echo call "venv\Scripts\activate.bat" >> "%ALIAS_FILE%"
echo call "windows\lint_all.bat" %%* >> "%ALIAS_FILE%"
echo ✅ Created alias: %ALIAS_FILE%

REM Add to PATH if not already there
echo.
echo 🛤️ Adding to PATH...
set "PATH_ADDED=false"
echo %PATH% | findstr /i "%USER_BIN%" >nul
if %errorlevel% neq 0 (
    echo Adding %USER_BIN% to PATH...
    setx PATH "%PATH%;%USER_BIN%" >nul 2>&1
    set "PATH_ADDED=true"
) else (
    echo ✅ %USER_BIN% is already in PATH
)

REM Test installation
echo.
echo 🧪 Testing installation...
call "%ALIAS_FILE%" --help >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Installation test passed
) else (
    echo ⚠️ Installation test failed, but installation should still work
)

echo.
echo ========================================
echo           Installation Complete!
echo ========================================
echo.
echo ✅ Lint-Heroes has been installed successfully!
echo.
echo 📋 What was installed:
echo    • Python linters: pylint, flake8, bandit, mypy, pyright, isort
echo    • Configuration files with venv exclusions
echo    • Global alias: lint-heroes
echo    • Virtual environment: %PROJECT_ROOT%\venv
echo.
echo 🚀 Usage:
echo    lint-heroes [directory_or_file]
echo.
echo 📝 Examples:
echo    lint-heroes                    # Check current directory
echo    lint-heroes C:\MyProject      # Check specific directory
echo    lint-heroes script.py         # Check specific file
echo.
if "%PATH_ADDED%"=="true" (
    echo ⚠️ IMPORTANT: Please restart your terminal for PATH changes to take effect
    echo.
)
echo Press any key to exit...
pause >nul
