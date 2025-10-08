@echo off
setlocal enabledelayedexpansion

REM Use local venv if exists
if exist ".venv" (
  call ".venv\Scripts\activate.bat"
)

set TARGET=%1
if "%TARGET%"=="" set TARGET=.

set is_dir=0
if exist "%TARGET%" (
  set is_dir=1
)

echo ▶ Linting target: %TARGET%

set status=0

REM Pylint
where pylint >nul 2>&1
if %errorlevel% equ 0 (
  echo.
  echo ---- pylint %TARGET% ----
  if exist ".pylintrc" (
    pylint --rcfile=.pylintrc "%TARGET%"
  ) else if exist "windows\.pylintrc" (
    pylint --rcfile=windows\.pylintrc "%TARGET%"
  ) else (
    pylint "%TARGET%"
  )
  if %errorlevel% neq 0 set status=1
) else (
  echo ⚠ pylint not found (skipping)
)

REM flake8 + bugbear
where flake8 >nul 2>&1
if %errorlevel% equ 0 (
  echo.
  echo ---- flake8 %TARGET% ----
  if exist ".flake8" (
    flake8 --config=.flake8 "%TARGET%"
  ) else if exist "windows\.flake8" (
    flake8 --config=windows\.flake8 "%TARGET%"
  ) else (
    flake8 "%TARGET%"
  )
  if %errorlevel% neq 0 set status=1
) else (
  echo ⚠ flake8 not found (skipping)
)

REM bandit
where bandit >nul 2>&1
if %errorlevel% equ 0 (
  echo.
  echo ---- bandit %TARGET% ----
  if exist "bandit.yaml" (
    if %is_dir%==1 (
      bandit -q -r -c bandit.yaml "%TARGET%"
    ) else (
      bandit -q -c bandit.yaml "%TARGET%"
    )
  ) else if exist "windows\bandit.yaml" (
    if %is_dir%==1 (
      bandit -q -r -c windows\bandit.yaml "%TARGET%"
    ) else (
      bandit -q -c windows\bandit.yaml "%TARGET%"
    )
  ) else (
    if %is_dir%==1 (
      bandit -q -r "%TARGET%"
    ) else (
      bandit -q "%TARGET%"
    )
  )
  if %errorlevel% neq 0 set status=1
) else (
  echo ⚠ bandit not found (skipping)
)

REM type check: prefer pyright, else mypy
where pyright >nul 2>&1
if %errorlevel% equ 0 (
  echo.
  echo ---- pyright %TARGET% ----
  if exist "pyrightconfig.json" (
    pyright "%TARGET%"
  ) else if exist "windows\pyrightconfig.json" (
    copy "windows\pyrightconfig.json" "pyrightconfig.json" >nul
    pyright "%TARGET%"
    del "pyrightconfig.json" >nul
  ) else (
    pyright "%TARGET%"
  )
  if %errorlevel% neq 0 set status=1
) else (
  where mypy >nul 2>&1
  if %errorlevel% equ 0 (
    echo.
    echo ---- mypy %TARGET% ----
    if exist "pyproject.toml" (
      mypy --config-file pyproject.toml "%TARGET%"
    ) else if exist "windows\pyproject.toml" (
      mypy --config-file windows\pyproject.toml "%TARGET%"
    ) else (
      mypy "%TARGET%"
    )
    if %errorlevel% neq 0 set status=1
  ) else (
    echo ⚠ Neither pyright nor mypy found (skipping type checks)
  )
)

echo.
if %status% neq 0 (
  echo ❌ Linting found issues.
) else (
  echo ✅ Linting passed.
)

exit /b %status%
