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
  pylint "%TARGET%"
  if %errorlevel% neq 0 set status=1
) else (
  echo ⚠ pylint not found (skipping)
)

REM flake8 + bugbear
where flake8 >nul 2>&1
if %errorlevel% equ 0 (
  echo.
  echo ---- flake8 %TARGET% ----
  flake8 "%TARGET%"
  if %errorlevel% neq 0 set status=1
) else (
  echo ⚠ flake8 not found (skipping)
)

REM bandit
where bandit >nul 2>&1
if %errorlevel% equ 0 (
  echo.
  echo ---- bandit %TARGET% ----
  if %is_dir%==1 (
    bandit -q -r "%TARGET%"
  ) else (
    bandit -q "%TARGET%"
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
  pyright "%TARGET%"
  if %errorlevel% neq 0 set status=1
) else (
  where mypy >nul 2>&1
  if %errorlevel% equ 0 (
    echo.
    echo ---- mypy %TARGET% ----
    mypy "%TARGET%"
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
