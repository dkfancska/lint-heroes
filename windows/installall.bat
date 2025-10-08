@echo off
setlocal enabledelayedexpansion

echo ▶ Detecting Python...

REM Find all available Python versions
set AVAILABLE_COUNT=0
for %%v in (python3.11 python3.12 python3.13 python3.10 python3.9 python3) do (
    where %%v >nul 2>&1
    if !errorlevel! equ 0 (
        set /a AVAILABLE_COUNT+=1
        set AVAILABLE_!AVAILABLE_COUNT!=%%v
    )
)

if %AVAILABLE_COUNT% equ 0 (
    echo ❌ No Python versions found. Install Python 3.9+ first.
    exit /b 1
)

REM If PY_BIN is set via environment variable, use it
if defined PY_BIN (
    where %PY_BIN% >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✔ Using specified Python: %PY_BIN%
        goto :check_version
    )
)

REM Interactive selection
echo Available Python versions:
set /a COUNTER=0
for /l %%i in (1,1,%AVAILABLE_COUNT%) do (
    set /a COUNTER+=1
    call set CURRENT_VERSION=%%AVAILABLE_!COUNTER!%%
    for /f "tokens=2" %%j in ('!CURRENT_VERSION! --version 2^>^&1') do set PY_VERSION=%%j
    where !CURRENT_VERSION!
    echo   !COUNTER!. !CURRENT_VERSION! ^(Python !PY_VERSION!^)
)

echo.
echo Select Python version for linting tools:
set /p CHOICE="Enter number (1-%AVAILABLE_COUNT%) or press Enter for default (1): "

REM Default to first option if no input
if "%CHOICE%"=="" set CHOICE=1

REM Validate choice
if %CHOICE% lss 1 set CHOICE=1
if %CHOICE% gtr %AVAILABLE_COUNT% set CHOICE=1

REM Set selected Python version
call set PY_BIN=%%AVAILABLE_!CHOICE!%%

:check_version
REM Check Python version
for /f "tokens=2" %%i in ('%PY_BIN% --version 2^>^&1') do set PY_VERSION=%%i
echo ✔ Selected Python %PY_VERSION% at:
where %PY_BIN%

REM Check if version is 3.9+ (minimum requirement)
%PY_BIN% -c "import sys; exit(0 if sys.version_info >= (3, 9) else 1)" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python %PY_VERSION% is too old. Python 3.9+ is required.
    echo   Detected version: %PY_VERSION%
    echo   Required: 3.9 or higher
    exit /b 1
)

REM Warn about older versions (but don't fail)
%PY_BIN% -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)" >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠ Warning: Python %PY_VERSION% found, but Python 3.11+ is recommended for best compatibility
    echo   Consider using a newer Python version if available
) else (
    echo ✔ Python version %PY_VERSION% is recommended
)

echo ▶ Creating virtualenv .venv (if missing)...
if not exist ".venv" (
    "%PY_BIN%" -m venv .venv
)

echo ▶ Activating virtual environment...
call .venv\Scripts\activate.bat

echo ▶ Upgrading pip...
pip install -U pip

echo ▶ Installing linters into .venv...
pip install -U ^
  pylint ^
  flake8 flake8-bugbear ^
  bandit ^
  mypy

echo ▶ Installing pyright (fast type checker)...
where pyright >nul 2>&1
if %errorlevel% equ 0 (
    echo ✔ pyright already installed
) else (
    echo ▶ Installing pyright via pip...
    pip install pyright || (
        echo ⚠ Failed to install pyright via pip.
        echo   You can install it manually: pip install pyright
        echo   Or download from: https://github.com/microsoft/pyright/releases
    )
)

echo ▶ Copying config files (won't overwrite existing)...

REM Copy config files from windows/ directory to project root
if not exist ".pylintrc" (
    if exist "windows\.pylintrc" (
        copy "windows\.pylintrc" ".pylintrc"
    ) else (
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
    )
)

if not exist ".flake8" (
    if exist "windows\.flake8" (
        copy "windows\.flake8" ".flake8"
    ) else (
        echo [flake8] > .flake8
        echo exclude = .venv,venv,build,dist,.mypy_cache,.pytest_cache,.git >> .flake8
        echo max-line-length = 120 >> .flake8
        echo extend-ignore = E203 >> .flake8
        echo select = B, E, F, W, B9 >> .flake8
    )
)

REM Copy other config files if they don't exist
if not exist "pyproject.toml" (
    if exist "windows\pyproject.toml" (
        copy "windows\pyproject.toml" "pyproject.toml"
    )
)

if not exist "bandit.yaml" (
    if exist "windows\bandit.yaml" (
        copy "windows\bandit.yaml" "bandit.yaml"
    )
)

if not exist "pyrightconfig.json" (
    if exist "windows\pyrightconfig.json" (
        copy "windows\pyrightconfig.json" "pyrightconfig.json"
    )
)

echo ▶ Creating aliases for easy access...

REM Create batch files in a directory that's in PATH
set ALIAS_DIR=%USERPROFILE%\bin
if not exist "%ALIAS_DIR%" mkdir "%ALIAS_DIR%"

REM Create lint-heroes.bat
echo @echo off > "%ALIAS_DIR%\lint-heroes.bat"
echo cd /d "%~dp0" >> "%ALIAS_DIR%\lint-heroes.bat"
echo call "%~dp0\windows\lint_all.bat" %%* >> "%ALIAS_DIR%\lint-heroes.bat"

REM Create lint-install.bat
echo @echo off > "%ALIAS_DIR%\lint-install.bat"
echo cd /d "%~dp0" >> "%ALIAS_DIR%\lint-install.bat"
echo call "%~dp0\windows\installall.bat" >> "%ALIAS_DIR%\lint-install.bat"

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

echo ✔ Aliases created in %ALIAS_DIR%
echo   - lint-heroes: run linting
echo   - lint-install: reinstall linters for current Python
echo   - lint-install-multiple: install for multiple Python versions
echo   - lint: shortcut for lint-heroes
echo   - lint-multi: shortcut for lint-install-multiple
echo.
echo ⚠ Add %ALIAS_DIR% to your PATH environment variable to use aliases globally
echo   Or run: setx PATH "%%PATH%%;%ALIAS_DIR%"

echo ▶ Creating lint_all.bat...
(
echo @echo off
echo setlocal enabledelayedexpansion
echo.
echo REM Use local venv if exists
echo if exist ".venv" ^(
echo   call ".venv\Scripts\activate.bat"
echo ^)
echo.
echo set TARGET=%1
echo if "%TARGET%"=="" set TARGET=.
echo.
echo set is_dir=0
echo if exist "%TARGET%" ^(
echo   set is_dir=1
echo ^)
echo.
echo echo ▶ Linting target: %TARGET%
echo.
echo set status=0
echo.
echo REM Pylint
echo where pylint ^>nul 2^>^&1
echo if %%errorlevel%% equ 0 ^(
echo   echo.
echo   echo ---- pylint %TARGET% ----
echo   pylint "%TARGET%"
echo   if %%errorlevel%% neq 0 set status=1
echo ^) else ^(
echo   echo ⚠ pylint not found ^(skipping^)
echo ^)
echo.
echo REM flake8 + bugbear
echo where flake8 ^>nul 2^>^&1
echo if %%errorlevel%% equ 0 ^(
echo   echo.
echo   echo ---- flake8 %TARGET% ----
echo   flake8 "%TARGET%"
echo   if %%errorlevel%% neq 0 set status=1
echo ^) else ^(
echo   echo ⚠ flake8 not found ^(skipping^)
echo ^)
echo.
echo REM bandit
echo where bandit ^>nul 2^>^&1
echo if %%errorlevel%% equ 0 ^(
echo   echo.
echo   echo ---- bandit %TARGET% ----
echo   if %%is_dir%%==1 ^(
echo     bandit -q -r "%TARGET%"
echo   ^) else ^(
echo     bandit -q "%TARGET%"
echo   ^)
echo   if %%errorlevel%% neq 0 set status=1
echo ^) else ^(
echo   echo ⚠ bandit not found ^(skipping^)
echo ^)
echo.
echo REM type check: prefer pyright, else mypy
echo where pyright ^>nul 2^>^&1
echo if %%errorlevel%% equ 0 ^(
echo   echo.
echo   echo ---- pyright %TARGET% ----
echo   pyright "%TARGET%"
echo   if %%errorlevel%% neq 0 set status=1
echo ^) else ^(
echo   where mypy ^>nul 2^>^&1
echo   if %%errorlevel%% equ 0 ^(
echo     echo.
echo     echo ---- mypy %TARGET% ----
echo     mypy "%TARGET%"
echo     if %%errorlevel%% neq 0 set status=1
echo   ^) else ^(
echo     echo ⚠ Neither pyright nor mypy found ^(skipping type checks^)
echo   ^)
echo ^)
echo.
echo echo.
echo if %%status%% neq 0 ^(
echo   echo ❌ Linting found issues.
echo ^) else ^(
echo   echo ✅ Linting passed.
echo ^)
echo.
echo exit /b %%status%%
) > lint_all.bat

echo ✔ Installation completed successfully!
pause
