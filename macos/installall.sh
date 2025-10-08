#!/usr/bin/env bash
set -euo pipefail

# Allow user to specify Python version via environment variable
# Usage: PY_BIN=python3.11 ./macos/installall.sh
echo "▶ Detecting Python..."

# Find all available Python versions
AVAILABLE_PYTHONS=()
for version in python3.11 python3.12 python3.13 python3.10 python3.9 python3; do
  if command -v "$version" >/dev/null 2>&1; then
    AVAILABLE_PYTHONS+=("$version")
  fi
done

if [ ${#AVAILABLE_PYTHONS[@]} -eq 0 ]; then
  echo "❌ No Python versions found. Install Python 3.9+ first." >&2
  exit 1
fi

# If PY_BIN is set via environment variable, use it
if [ -n "${PY_BIN:-}" ] && command -v "$PY_BIN" >/dev/null 2>&1; then
  echo "✔ Using specified Python: $PY_BIN"
else
  # Interactive selection
  echo "Available Python versions:"
  for i in "${!AVAILABLE_PYTHONS[@]}"; do
    version="${AVAILABLE_PYTHONS[$i]}"
    py_version=$("$version" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    location=$(which "$version")
    echo "  $((i+1)). $version (Python $py_version) at $location"
  done
  
  echo ""
  echo "Select Python version for linting tools:"
  read -p "Enter number (1-${#AVAILABLE_PYTHONS[@]}) or press Enter for default (1): " choice
  
  # Default to first option if no input
  choice=${choice:-1}
  
  # Validate choice
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#AVAILABLE_PYTHONS[@]} ]; then
    echo "❌ Invalid selection. Using default: ${AVAILABLE_PYTHONS[0]}"
    choice=1
  fi
  
  PY_BIN="${AVAILABLE_PYTHONS[$((choice-1))]}"
fi

# Check Python version
PY_VERSION=$("$PY_BIN" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
echo "✔ Selected Python $PY_VERSION at: $(which "$PY_BIN")"

# Check if version is 3.9+ (minimum requirement)
if ! "$PY_BIN" -c "import sys; exit(0 if sys.version_info >= (3, 9) else 1)" 2>/dev/null; then
  echo "❌ Python $PY_VERSION is too old. Python 3.9+ is required."
  exit 1
fi

# Warn about older versions
if ! "$PY_BIN" -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)" 2>/dev/null; then
  echo "⚠ Warning: Python $PY_VERSION found, but Python 3.11+ is recommended for best compatibility"
  echo "  Consider using a newer Python version if available"
fi

echo "▶ Creating virtualenv .venv (if missing)..."
if [ ! -d ".venv" ]; then
  "$PY_BIN" -m venv .venv
fi
# shellcheck source=/dev/null
source .venv/bin/activate

echo "▶ Upgrading pip..."
pip install -U pip

echo "▶ Installing linters into .venv..."
pip install -U \
  pylint \
  flake8 flake8-bugbear \
  bandit \
  mypy

# Install pyright (fast type checker) without Node.js
install_pyright() {
  if command -v pyright >/dev/null 2>&1; then
    echo "✔ pyright already installed: $(pyright --version || true)"
    return 0
  fi
  
  # Try Homebrew first (no Node.js required)
  if command -v brew >/dev/null 2>&1; then
    echo "▶ Installing pyright via Homebrew..."
    brew install pyright || true
  else
    echo "⚠ Homebrew not found. Skipping pyright install."
    echo "  Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  Then run: brew install pyright"
  fi
}

install_pyright

echo "▶ Copying config files (won't overwrite existing)..."

# Copy config files from macos/ directory to project root
if [ ! -f ".pylintrc" ]; then
  if [ -f "macos/.pylintrc" ]; then
    cp macos/.pylintrc .pylintrc
  else
    # Create default .pylintrc if not found
    cat > .pylintrc <<'EOF'
[MASTER]
ignore=venv,.venv,build,dist,.mypy_cache,.pytest_cache,.idea,.git

[MESSAGES CONTROL]
disable=C0114,C0115,C0116  ; ignore missing module/class/function docstrings

[REPORTS]
score = no

[TYPECHECK]
generated-members=requests.*,numpy.*

[FORMAT]
max-line-length=120
EOF
  fi
fi

if [ ! -f ".flake8" ]; then
  if [ -f "macos/.flake8" ]; then
    cp macos/.flake8 .flake8
  else
    # Create default .flake8 if not found
    cat > .flake8 <<'EOF'
[flake8]
exclude = .venv,venv,build,dist,.mypy_cache,.pytest_cache,.idea,.git
max-line-length = 120
extend-ignore = E203
select = B, E, F, W, B9
EOF
  fi
fi

# Copy pyproject.toml if it doesn't exist
if [ ! -f "pyproject.toml" ]; then
  if [ -f "macos/pyproject.toml" ]; then
    cp macos/pyproject.toml pyproject.toml
  fi
fi

# Copy bandit.yaml if it doesn't exist
if [ ! -f "bandit.yaml" ]; then
  if [ -f "macos/bandit.yaml" ]; then
    cp macos/bandit.yaml bandit.yaml
  fi
fi

# Copy pyrightconfig.json if it doesn't exist
if [ ! -f "pyrightconfig.json" ]; then
  if [ -f "macos/pyrightconfig.json" ]; then
    cp macos/pyrightconfig.json pyrightconfig.json
  fi
fi

echo "▶ Creating aliases for easy access..."

# Create aliases in shell profile
SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

if [ -n "$SHELL_PROFILE" ]; then
    # Check if aliases already exist
    if ! grep -q "alias lint-heroes" "$SHELL_PROFILE"; then
        echo "" >> "$SHELL_PROFILE"
        echo "# Lint Heroes aliases" >> "$SHELL_PROFILE"
        echo "alias lint-heroes='$PWD/lint_all.sh'" >> "$SHELL_PROFILE"
        echo "alias lint-install='$PWD/installall.sh'" >> "$SHELL_PROFILE"
        echo "alias lint-install-multiple='$PWD/install_multiple.sh'" >> "$SHELL_PROFILE"
        echo "alias lint='lint-heroes'" >> "$SHELL_PROFILE"
        echo "alias lint-multi='lint-install-multiple'" >> "$SHELL_PROFILE"
        echo "✔ Aliases added to $SHELL_PROFILE"
        echo "  - lint-heroes: run linting"
        echo "  - lint-install: reinstall linters for current Python"
        echo "  - lint-install-multiple: install for multiple Python versions"
        echo "  - lint: shortcut for lint-heroes"
        echo "  - lint-multi: shortcut for lint-install-multiple"
        echo "  Run 'source $SHELL_PROFILE' or restart terminal to use aliases"
    else
        echo "✔ Aliases already exist in $SHELL_PROFILE"
    fi
else
    echo "⚠ No shell profile found. Add these aliases manually:"
    echo "  alias lint-heroes='$PWD/lint_all.sh'"
    echo "  alias lint-install='$PWD/installall.sh'"
    echo "  alias lint-install-multiple='$PWD/install_multiple.sh'"
    echo "  alias lint='lint-heroes'"
    echo "  alias lint-multi='lint-install-multiple'"
fi

echo "▶ Creating lint_all.sh..."
cat > lint_all.sh <<'EOF'
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
EOF

chmod +x lint_all.sh

echo "▶ Adding shared Run configuration for PyCharm (.run/Lint All.run.xml)..."
mkdir -p .run
cat > ".run/Lint All.run.xml" <<'EOF'
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Lint All" type="ShConfigurationType">
    <option name="SCRIPT_PATH" value="$PROJECT_DIR$/lint_all.sh" />
    <option name="SCRIPT_OPTIONS" value="" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="WORKING_DIRECTORY" value="$PROJECT_DIR$" />
    <option name="EXECUTE_IN_TERMINAL" value="true" />
    <method v="2" />
  </configuration>
</component>
EOF

cat <<'EOF'
▶ Done.

Next steps:
  1) chmod +x setup_mac_linting.sh
  2) ./setup_mac_linting.sh
  3) In PyCharm: select Run configuration 'Lint All' and Run (or assign a shortcut).
  4) To lint a single file: run 'lint_all.sh path/to/file.py' from terminal
     or edit Run configuration and add '$FilePath$' to SCRIPT_OPTIONS.
EOF
