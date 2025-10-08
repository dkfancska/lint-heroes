#!/usr/bin/env bash
set -euo pipefail

# Use local venv if exists
if [ -d ".venv" ]; then
  # shellcheck source=/dev/null
  source ".venv/bin/activate"
fi

TARGET="${1:-$PWD}"

is_dir=0
if [ -d "$TARGET" ]; then
  is_dir=1
fi

echo "==> Linting target: $TARGET"

status=0

run() {
  echo ""
  echo "---- $*"
  if ! "$@"; then
    status=1
  fi
}

# Pylint
if command -v pylint >/dev/null 2>&1; then
  if [ "$is_dir" -eq 1 ]; then
    run pylint "$TARGET"
  else
    run pylint "$TARGET"
  fi
else
  echo "⚠ pylint not found (skipping)"
fi

# flake8 + bugbear
if command -v flake8 >/dev/null 2>&1; then
  if [ "$is_dir" -eq 1 ]; then
    run flake8 "$TARGET"
  else
    run flake8 "$TARGET"
  fi
else
  echo "⚠ flake8 not found (skipping)"
fi

# bandit
if command -v bandit >/dev/null 2>&1; then
  if [ "$is_dir" -eq 1 ]; then
    run bandit -q -r "$TARGET"
  else
    run bandit -q "$TARGET"
  fi
else
  echo "⚠ bandit not found (skipping)"
fi

# type check: prefer pyright, else mypy
if command -v pyright >/dev/null 2>&1; then
  run pyright "$TARGET"
elif command -v mypy >/dev/null 2>&1; then
  run mypy "$TARGET"
else
  echo "⚠ Neither pyright nor mypy found (skipping type checks)"
fi

echo ""
if [ $status -ne 0 ]; then
  echo "❌ Linting found issues."
else
  echo "✅ Linting passed."
fi

exit $status
