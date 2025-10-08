# Troubleshooting Guide

## Common Issues

### Python Version Issues

#### Python Not Found
```bash
# Check available Python versions
which python3.11 python3.12 python3.10 python3.9 python3

# Windows
where python3.11 python3.12 python3.10 python3.9 python3
```

**Solution:**
- Install Python 3.9+ from [python.org](https://python.org)
- Ensure Python is in PATH
- Use full path: `/usr/bin/python3.11` or `C:\Python311\python.exe`

#### Wrong Python Version Selected
```bash
# Force specific version
PY_BIN=python3.11 ./macos/installall.sh

# Windows PowerShell
.\windows\installall.ps1 -PythonPath python3.11
```

#### Multiple Python Versions Conflict
```bash
# Check which Python is being used
which python
python --version

# Use specific version
python3.11 -m venv .venv
source .venv/bin/activate
```

### Installation Issues

#### Virtual Environment Problems
```bash
# Remove and recreate
rm -rf .venv
./macos/installall.sh

# Windows
rmdir /s .venv
windows\installall.bat
```

#### Permission Denied
```bash
# Make scripts executable
chmod +x macos/*.sh
chmod +x windows/*.ps1

# Run with sudo (if needed)
sudo ./macos/installall.sh
```

#### Package Installation Fails
```bash
# Upgrade pip
pip install --upgrade pip

# Install with specific Python
python3.11 -m pip install -r req.txt

# Use uv (alternative)
uv pip install -r req.txt
```

### Alias Issues

#### Aliases Not Working
```bash
# Check if aliases exist
grep "lint-heroes" ~/.zshrc

# Reload shell profile
source ~/.zshrc

# Windows - check PATH
echo %PATH%
```

**Solution:**
```bash
# Recreate aliases
./fix_aliases.sh

# Or manually add to shell profile
echo 'alias lint-heroes="/path/to/lint_heroes/macos/lint_all.sh"' >> ~/.zshrc
```

#### Wrong Path in Aliases
```bash
# Check current aliases
alias lint-heroes

# Fix aliases
./fix_aliases.sh
```

### Tool-Specific Issues

#### Pylint Not Found
```bash
# Check installation
pip list | grep pylint

# Reinstall
pip install pylint

# Check virtual environment
which pylint
```

#### Flake8 Issues
```bash
# Check flake8 installation
pip list | grep flake8

# Install flake8-bugbear
pip install flake8-bugbear

# Check configuration
flake8 --config=.flake8 --help
```

#### Bandit Security Warnings
```bash
# Check bandit configuration
bandit --config=bandit.yaml --help

# Skip specific checks
bandit -s B311 your_file.py

# Update bandit.yaml
echo "skips: [B311]" > bandit.yaml
```

#### MyPy Type Errors
```bash
# Check mypy configuration
mypy --config-file=pyproject.toml --help

# Ignore missing imports
mypy --ignore-missing-imports your_file.py

# Update pyproject.toml
echo '[tool.mypy]
ignore_missing_imports = true' >> pyproject.toml
```

#### Pyright Not Found
```bash
# Install via npm
npm install -g pyright

# Check installation
pyright --version

# Alternative: use mypy instead
mypy your_file.py
```

### Windows-Specific Issues

#### PowerShell Execution Policy
```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy (run as administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bypass
PowerShell -ExecutionPolicy Bypass -File .\windows\installall.ps1
```

#### Path Issues
```cmd
# Check Python in PATH
echo %PATH%

# Add Python to PATH
setx PATH "%PATH%;C:\Python311;C:\Python311\Scripts"
```

#### npm/pyright Issues
```cmd
# Install Node.js from nodejs.org
# Check installation
node --version
npm --version

# Install pyright
npm install -g pyright
```

### macOS-Specific Issues

#### Homebrew Issues
```bash
# Update Homebrew
brew update

# Install Python
brew install python@3.11

# Install pyright
brew install pyright
```

#### Permission Issues
```bash
# Fix permissions
sudo chown -R $(whoami) /usr/local/bin

# Or use user installation
pip install --user pylint flake8 bandit mypy
```

### Linux-Specific Issues

#### Package Manager Issues
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-pip

# CentOS/RHEL
sudo yum install python311 python311-pip

# Arch Linux
sudo pacman -S python python-pip
```

#### Virtual Environment Issues
```bash
# Install venv module
sudo apt install python3.11-venv

# Create virtual environment
python3.11 -m venv .venv
source .venv/bin/activate
```

## Performance Issues

### Slow Linting
```bash
# Use faster tools
pyright your_file.py  # Instead of mypy

# Limit file scope
lint-heroes src/main.py  # Instead of entire directory

# Use parallel processing
pylint --jobs=4 your_file.py
```

### Memory Issues
```bash
# Reduce memory usage
pylint --disable=all --enable=C0114 your_file.py

# Use lighter tools
flake8 your_file.py  # Instead of pylint
```

## Configuration Issues

### Invalid Configuration
```bash
# Validate TOML syntax
python -c "import tomllib; tomllib.load(open('pyproject.toml', 'rb'))"

# Validate YAML syntax
python -c "import yaml; yaml.safe_load(open('bandit.yaml', 'r'))"
```

### Conflicting Configurations
```bash
# Check for multiple config files
find . -name ".pylintrc" -o -name ".flake8" -o -name "setup.cfg"

# Remove conflicting files
rm -f setup.cfg tox.ini
```

## Getting Help

### Debug Mode
```bash
# Run with verbose output
pylint --verbose your_file.py
flake8 --verbose your_file.py
bandit --verbose your_file.py
mypy --verbose your_file.py
```

### Check Tool Versions
```bash
# Check all tool versions
pylint --version
flake8 --version
bandit --version
mypy --version
pyright --version
```

### Log Files
```bash
# Check for log files
ls -la *.log
tail -f pylint.log
```

### Community Support
- [GitHub Issues](https://github.com/dkfancska/lint-heroes/issues)
- [GitHub Discussions](https://github.com/dkfancska/lint-heroes/discussions)
- [Python Community](https://www.python.org/community/)

## Reset Everything

### Complete Reset
```bash
# Remove all virtual environments
rm -rf .venv .venv-*

# Remove configuration files
rm -f .pylintrc .flake8

# Remove aliases from shell profile
sed -i '/# Lint Heroes aliases/,/alias lint-multi=/d' ~/.zshrc

# Reinstall everything
./macos/installall.sh
```

### Partial Reset
```bash
# Reset only virtual environment
rm -rf .venv
./macos/installall.sh

# Reset only aliases
./fix_aliases.sh
```

## Reporting Issues

When reporting issues, please include:

1. **Operating System:** macOS/Windows/Linux version
2. **Python Version:** `python --version`
3. **Tool Versions:** `pylint --version`, `flake8 --version`, etc.
4. **Error Messages:** Full error output
5. **Steps to Reproduce:** Exact commands that caused the issue
6. **Expected Behavior:** What should have happened
7. **Actual Behavior:** What actually happened
