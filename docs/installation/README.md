# Installation Guide

## Prerequisites

- Python 3.9+ (3.11+ recommended)
- Package manager `uv` (optional)
- Docker (for containerized workflows)
- Homebrew (macOS, for pyright installation)

## Quick Installation

### macOS/Linux
```bash
git clone https://github.com/dkfancska/lint-heroes.git
cd lint-heroes
./macos/installall.sh
```

### Windows
```powershell
git clone https://github.com/dkfancska/lint-heroes.git
cd lint-heroes
.\windows\installall.ps1
```

## Python Version Selection

### Interactive Selection

When you run the installation script, you'll see a list of available Python versions:

```
Available Python versions:
  1. python3.11 (Python 3.11.0) at /usr/bin/python3.11
  2. python3.12 (Python 3.12.0) at /usr/bin/python3.12
  3. python3.10 (Python 3.10.0) at /usr/bin/python3.10

Select Python version for linting tools:
Enter number (1-3) or press Enter for default (1):
```

### Multiple Python Versions

Install linting tools for multiple Python versions:

**macOS/Linux:**
```bash
./macos/install_multiple.sh
# or
lint-multi
```

**Windows:**
```powershell
.\windows\install_multiple.ps1
# or
lint-multi
```

### Manual Version Selection

**macOS/Linux:**
```bash
PY_BIN=python3.11 ./macos/installall.sh
```

**Windows PowerShell:**
```powershell
.\windows\installall.ps1 -PythonPath python3.11
```

## Pyright Installation

### macOS/Linux

Pyright is installed via Homebrew (no Node.js required):

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Pyright will be installed automatically via Homebrew
```

### Windows

Pyright is installed via pip (no Node.js required):

```bash
# Pyright will be installed automatically via pip
pip install pyright
```

### Manual Installation

If automatic installation fails:

**macOS/Linux:**
```bash
brew install pyright
```

**Windows:**
```bash
pip install pyright
```

**Alternative (all platforms):**
- Download from [GitHub releases](https://github.com/microsoft/pyright/releases)
- Extract and add to PATH

## Installation Methods

### Method 1: Automated Scripts (Recommended)

The installation scripts will:
- Detect available Python versions
- Create virtual environments
- Install all linting tools
- Create shell aliases
- Set up configurations

### Shell Aliases Created

#### macOS/Linux
- `lint-heroes` - run all linters
- `lint-install` - reinstall linters for current Python
- `lint-install-multiple` - install for multiple Python versions
- `lint` - shortcut for lint-heroes
- `lint-multi` - shortcut for lint-install-multiple

#### Windows

**Batch Files (Command Prompt):**
- `lint-heroes.bat` - run all linters
- `lint-install.bat` - reinstall linters for current Python
- `lint-install-multiple.bat` - install for multiple Python versions
- `lint.bat` - shortcut for lint-heroes
- `lint-multi.bat` - shortcut for lint-install-multiple

**PowerShell Functions:**
- `lint-heroes` - run all linters
- `lint-install` - reinstall linters for current Python
- `lint-install-multiple` - install for multiple Python versions
- `lint` - shortcut for lint-heroes
- `lint-multi` - shortcut for lint-install-multiple

### Method 2: Manual Installation

```bash
# Create virtual environment
python3.11 -m venv .venv
source .venv/bin/activate  # Linux/macOS
# or
.venv\Scripts\activate.bat  # Windows

# Install tools
pip install -r req.txt

# Install pyright (optional)
npm install -g pyright
```

### Method 3: Using uv (Alternative)

```bash
# Install with uv
uv pip install -r req.txt

# Install pyright
npm install -g pyright
```

## Post-Installation

### Activate Aliases

**macOS/Linux:**
```bash
source ~/.zshrc  # or ~/.bashrc
```

**Windows:**

**Batch Files (Command Prompt):**
- Created in: `%USERPROFILE%\bin\`
- Added to PATH automatically
- Restart Command Prompt to use

**PowerShell Functions:**
- Added to PowerShell profile: `$PROFILE`
- Available immediately in new PowerShell sessions
- To reload in current session:
```powershell
. $PROFILE
```

### Verify Installation

**macOS/Linux:**
```bash
# Check if aliases work
lint-heroes --help

# Check individual tools
pylint --version
flake8 --version
bandit --version
mypy --version
pyright --version
```

**Windows:**

**Command Prompt:**
```cmd
# Check if batch files work
lint-heroes --help

# Check individual tools
pylint --version
flake8 --version
bandit --version
mypy --version
pyright --version
```

**PowerShell:**
```powershell
# Check if functions work
lint-heroes --help

# Check individual tools
pylint --version
flake8 --version
bandit --version
mypy --version
pyright --version
```

## Virtual Environment Structure

After installation, you'll have:

```
lint_heroes/
├── .venv/              # Main environment
├── .venv-3.11/         # Python 3.11 environment
├── .venv-3.12/         # Python 3.12 environment
└── ...
```

## Troubleshooting

### Python Not Found
```bash
# Check available Python versions
which python3.11 python3.12 python3.10 python3.9 python3

# Windows
where python3.11 python3.12 python3.10 python3.9 python3
```

### Aliases Not Working
```bash
# Check if aliases are in shell profile
grep "lint-heroes" ~/.zshrc

# Reload profile
source ~/.zshrc
```

**Windows:**

**Command Prompt:**
```cmd
# Check if batch files exist
dir "%USERPROFILE%\bin\lint*.bat"

# Check PATH
echo %PATH% | findstr "%USERPROFILE%\bin"
```

**PowerShell:**
```powershell
# Check if functions are in profile
Get-Content $PROFILE | Select-String "lint-heroes"

# Reload profile
. $PROFILE
```

### Virtual Environment Issues
```bash
# Remove and recreate
rm -rf .venv
./macos/installall.sh
```

For more troubleshooting, see the [Troubleshooting Guide](../troubleshooting/README.md).
