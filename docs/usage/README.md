# Usage Guide

## Basic Usage

### Running Linters

```bash
# Lint current directory
lint-heroes

# Lint specific file
lint-heroes src/main.py

# Lint specific directory
lint-heroes src/

# Lint with specific Python version
source .venv-3.11/bin/activate
lint-heroes
deactivate
```

### Individual Tools

```bash
# Pylint - Static code analysis
pylint your_file.py

# Flake8 - Style guide enforcement
flake8 your_file.py

# Bandit - Security linter
bandit -r your_directory/

# MyPy - Type checking
mypy your_file.py

# Pyright - Fast type checking
pyright your_file.py

# isort - Import sorting
isort your_file.py
```

## Aliases Reference

### macOS/Linux
| Alias | Description |
|-------|-------------|
| `lint-heroes` | Run all linters |
| `lint-install` | Install for current Python |
| `lint-install-multiple` | Install for multiple Python versions |
| `lint` | Short alias for lint-heroes |
| `lint-multi` | Short alias for lint-install-multiple |

### Windows

#### Batch Files (Command Prompt)
| Alias | Description |
|-------|-------------|
| `lint-heroes` | Run all linters |
| `lint-install` | Install for current Python |
| `lint-install-multiple` | Install for multiple Python versions |
| `lint` | Short alias for lint-heroes |
| `lint-multi` | Short alias for lint-install-multiple |

#### PowerShell Functions
| Function | Description |
|----------|-------------|
| `lint-heroes` | Run all linters |
| `lint-install` | Install for current Python |
| `lint-install-multiple` | Install for multiple Python versions |
| `lint` | Short alias for lint-heroes |
| `lint-multi` | Short alias for lint-install-multiple |

## Working with Multiple Python Versions

### Installation for Multiple Versions

```bash
# Interactive installation
lint-multi

# Select versions you want to install
# Example: 1 3 5 (for versions 1, 3, and 5)
```

### Using Specific Python Versions

**macOS/Linux:**
```bash
# For Python 3.11
source .venv-3.11/bin/activate
pylint your_file.py
deactivate

# For Python 3.12
source .venv-3.12/bin/activate
pylint your_file.py
deactivate
```

**Windows:**
```cmd
# For Python 3.11
.venv-3.11\Scripts\activate.bat
pylint your_file.py
deactivate

# For Python 3.12
.venv-3.12\Scripts\activate.bat
pylint your_file.py
deactivate
```

**Windows PowerShell:**
```powershell
# For Python 3.11
& .venv-3.11\Scripts\Activate.ps1
pylint your_file.py
deactivate

# For Python 3.12
& .venv-3.12\Scripts\Activate.ps1
pylint your_file.py
deactivate
```

### Creating Version-Specific Scripts

**macOS/Linux:**
```bash
# Create lint-311.sh
#!/bin/bash
source .venv-3.11/bin/activate
pylint "$@"
deactivate

# Create lint-312.sh
#!/bin/bash
source .venv-3.12/bin/activate
pylint "$@"
deactivate

# Make executable
chmod +x lint-311.sh lint-312.sh
```

**Windows:**
```cmd
# Create lint-311.bat
@echo off
call .venv-3.11\Scripts\activate.bat
pylint %*
deactivate

# Create lint-312.bat
@echo off
call .venv-3.12\Scripts\activate.bat
pylint %*
deactivate
```

## IDE Integration

### PyCharm

The project includes PyCharm run configurations:
- **macOS/Linux**: `.run/Lint All.run.xml`
- **Windows Batch**: `.run/Lint All Windows.run.xml`
- **Windows PowerShell**: `.run/Lint All PowerShell.run.xml`

### VS Code

**settings.json:**
```json
{
    "python.defaultInterpreterPath": ".venv\\Scripts\\python.exe",
    "python.terminal.activateEnvironment": true,
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.banditEnabled": true,
    "python.linting.mypyEnabled": true
}
```

## Docker Usage

```bash
# Build Docker image
docker build -t lint-heroes .

# Run linting in container
docker run -v $(pwd):/workspace lint-heroes /workspace

# Windows PowerShell
docker run -v ${PWD}:/workspace lint-heroes /workspace
```

## Advanced Usage

### Custom Configurations

```bash
# Use custom pylint config
pylint --rcfile=my_pylintrc your_file.py

# Use custom flake8 config
flake8 --config=my_flake8 your_file.py

# Use custom mypy config
mypy --config-file=my_mypy.ini your_file.py
```

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: lint-heroes
        name: lint-heroes
        entry: lint-heroes
        language: system
        files: \.py$
```

### CI/CD Integration

**GitHub Actions:**
```yaml
name: Lint
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.11'
      - name: Install lint-heroes
        run: |
          git clone https://github.com/dkfancska/lint-heroes.git
          cd lint-heroes
          ./macos/installall.sh
      - name: Run linters
        run: lint-heroes
```

## Examples

### Linting a Django Project

```bash
# Lint Django project
lint-heroes myproject/

# Lint specific Django app
lint-heroes myproject/apps/
```

### Linting a FastAPI Project

```bash
# Lint FastAPI project
lint-heroes app/

# Lint with type checking
mypy app/
```

### Linting a Data Science Project

```bash
# Lint Jupyter notebooks (if converted to .py)
lint-heroes notebooks/

# Lint with specific Python version for data science
source .venv-3.11/bin/activate
lint-heroes data_analysis/
deactivate
```
