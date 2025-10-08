# Lint-Heroes Installation Guide

## Prerequisites

- Python 3.9+ (3.11+ recommended)
- Package manager `uv` (optional)
- Docker (for containerized workflows)
- Homebrew (macOS, for pyright installation)

## Quick Installation

### Windows
```cmd
git clone https://github.com/dkfancska/lint-heroes.git
cd lint-heroes
windows\install_universal.bat
```

### macOS/Linux
```bash
git clone https://github.com/dkfancska/lint-heroes.git
cd lint-heroes
./macos/installall.sh
```

## What the installer does:

1. **Checks Python installation** - Ensures Python is installed and in PATH
2. **Creates virtual environment** - Sets up isolated environment for linters
3. **Installs linters** - Downloads pylint, flake8, bandit, mypy, pyright, isort
4. **Creates configuration files** - Sets up configs with venv exclusions
5. **Creates global alias** - Makes `lint-heroes` available from anywhere
6. **Adds to PATH** - Automatically adds user bin directory to PATH

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
```cmd
windows\install_universal.bat
# or
lint-heroes
```

## Usage:

After installation, you can use `lint-heroes` from anywhere:

```cmd
# Check current directory
lint-heroes

# Check specific directory
lint-heroes C:\MyProject

# Check specific file
lint-heroes script.py
```

## Manual Installation:

If the automatic installer doesn't work, you can install manually:

1. **Clone the repository:**
   ```cmd
   git clone https://github.com/dkfancska/lint-heroes.git
   cd lint-heroes
   ```

2. **Create and activate a virtual environment:**
   ```cmd
   python -m venv venv
   .\venv\Scripts\activate  # Windows
   # or
   source .venv/bin/activate  # macOS/Linux
   ```

3. **Install tools:**
   ```cmd
   pip install -r req.txt
   ```

4. **Install with uv (Alternative):**
   ```bash
   # Install with uv
   uv pip install -r req.txt

   # Install pyright
   npm install -g pyright
   ```

5. **Create configuration files** (copy from `windows/` or `macos/` directory)

6. **Create alias:**
   ```cmd
   # Windows: Create %USERPROFILE%\bin\lint-heroes.bat
   @echo off
   cd /d "C:\path\to\lint-heroes"
   call "venv\Scripts\activate.bat"
   call "windows\lint_all.bat" %*
   ```

   ```bash
   # macOS/Linux: Create ~/bin/lint-heroes
   #!/bin/bash
   cd /path/to/lint-heroes
   source .venv/bin/activate
   ./macos/lint_all.sh "$@"
   ```

7. **Add to PATH:**
   ```cmd
   # Windows
   setx PATH "%PATH%;%USERPROFILE%\bin"
   ```

   ```bash
   # macOS/Linux
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Troubleshooting:

### "Python is not installed"
- Download Python from https://python.org
- Make sure to check "Add Python to PATH" during installation
- Restart your terminal after installation

### "lint-heroes command not found"
- Restart your terminal after installation
- Check if `%USERPROFILE%\bin` (Windows) or `~/bin` (macOS/Linux) is in your PATH
- Manually add it to PATH

### "Permission denied" (PowerShell)
- Run Command Prompt as Administrator
- Or check that Python is properly installed

### "Permission denied" (macOS/Linux)
- Make the script executable: `chmod +x macos/installall.sh`
- Or run with sudo if needed

## Uninstall:

To uninstall lint-heroes:

1. Remove the virtual environment: `rmdir /s /q venv` (Windows) or `rm -rf .venv` (macOS/Linux)
2. Remove the alias: `del "%USERPROFILE%\bin\lint-heroes.bat"` (Windows) or `rm ~/bin/lint-heroes` (macOS/Linux)
3. Remove from PATH: `setx PATH "%PATH%"` (Windows) or remove from ~/.bashrc (macOS/Linux)

## Support:

If you encounter issues:

1. Check that Python is installed and in PATH
2. Ensure you have internet connection
3. Try running as Administrator (Windows)
4. Check the platform-specific README files for detailed information
