#!/usr/bin/env bash
set -euo pipefail

echo "🐍 Lint Heroes - Multiple Python Versions Installer"
echo "=================================================="

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

echo "Available Python versions:"
for i in "${!AVAILABLE_PYTHONS[@]}"; do
  version="${AVAILABLE_PYTHONS[$i]}"
  py_version=$("$version" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  location=$(which "$version")
  echo "  $((i+1)). $version (Python $py_version) at $location"
done

echo ""
echo "Select Python versions to install linting tools for:"
echo "Enter numbers separated by spaces (e.g., 1 3 5) or 'all' for all versions:"
read -p "Your choice: " choices

# Parse choices
SELECTED_PYTHONS=()
if [[ "$choices" == "all" ]]; then
  SELECTED_PYTHONS=("${AVAILABLE_PYTHONS[@]}")
else
  for choice in $choices; do
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#AVAILABLE_PYTHONS[@]} ]; then
      SELECTED_PYTHONS+=("${AVAILABLE_PYTHONS[$((choice-1))]}")
    else
      echo "⚠ Invalid choice: $choice (skipping)"
    fi
  done
fi

if [ ${#SELECTED_PYTHONS[@]} -eq 0 ]; then
  echo "❌ No valid Python versions selected."
  exit 1
fi

echo ""
echo "Selected Python versions:"
for version in "${SELECTED_PYTHONS[@]}"; do
  py_version=$("$version" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  echo "  - $version (Python $py_version)"
done

echo ""
read -p "Continue with installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Installation cancelled."
  exit 0
fi

# Install for each selected Python version
for py_bin in "${SELECTED_PYTHONS[@]}"; do
  echo ""
  echo "=========================================="
  echo "Installing for $py_bin"
  echo "=========================================="
  
  # Create version-specific virtual environment
  venv_name=".venv-$(echo "$py_bin" | sed 's/python//')"
  echo "▶ Creating virtualenv $venv_name..."
  "$py_bin" -m venv "$venv_name"
  
  # Activate virtual environment
  source "$venv_name/bin/activate"
  
  # Upgrade pip
  echo "▶ Upgrading pip..."
  pip install -U pip
  
  # Install linters
  echo "▶ Installing linters..."
  pip install -U \
    pylint \
    flake8 flake8-bugbear \
    bandit \
    mypy \
    isort
  
  # Install pyright if available
  if command -v npm >/dev/null 2>&1; then
    echo "▶ Installing pyright..."
    npm install -g pyright || echo "⚠ Failed to install pyright"
  fi
  
  # Deactivate virtual environment
  deactivate
  
  echo "✅ Installation completed for $py_bin"
done

echo ""
echo "🎉 Installation completed for all selected Python versions!"
echo ""
echo "Usage examples:"
for py_bin in "${SELECTED_PYTHONS[@]}"; do
  venv_name=".venv-$(echo "$py_bin" | sed 's/python//')"
  echo "  # For $py_bin:"
  echo "  source $venv_name/bin/activate"
  echo "  pylint your_file.py"
  echo "  deactivate"
  echo ""
done
