# Configuration Guide

## Overview

Lint Heroes uses multiple configuration files to customize linting behavior:

- `pyproject.toml` - Main configuration for isort, pyright, mypy
- `bandit.yaml` - Security linter configuration
- `pyrightconfig.json` - Pyright type checker configuration
- `.pylintrc` - Pylint configuration (auto-generated)
- `.flake8` - Flake8 configuration (auto-generated)

## pyproject.toml

Main configuration file for most tools:

```toml
[tool.isort]
# Import sorting configuration
profile = "black"
line_length = 120
multi_line_output = 3
include_trailing_comma = true
use_parentheses = true
force_grid_wrap = 0
combine_as_imports = true
known_first_party = ["app", "src", "project"]
known_third_party = ["airflow", "pendulum", "flask", "requests", "pyspark"]
default_section = "THIRDPARTY"
skip = [".venv", "venv", "build", "dist", ".mypy_cache", ".pytest_cache", ".idea", ".git"]

[tool.pyright]
# Pyright type checker configuration
pythonVersion = "3.11"
typeCheckingMode = "strict"
reportMissingImports = true
reportOptionalMemberAccess = true
reportOptionalCall = true
reportUnknownParameterType = true
reportUnknownArgumentType = true

[tool.mypy]
# MyPy type checker configuration
python_version = "3.11"
ignore_missing_imports = true
strict_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
no_implicit_optional = true
disallow_untyped_defs = false
exclude = '(\\.venv|venv|build|dist|\\.mypy_cache|\\.pytest_cache|\\.idea|\\.git)'

[flake8]
# Flake8 configuration
exclude = ['.git', '__pycache__', 'docs/', 'old/']
max-line-length = 150
```

## bandit.yaml

Security linter configuration:

```yaml
skips:
  - B311  # Skip random module check
exclude_dirs:
  - .venv
  - venv
  - build
  - dist
  - .mypy_cache
  - .pytest_cache
  - .idea
  - .git
```

## pyrightconfig.json

Pyright type checker configuration:

```json
{
  "$schema": "https://raw.githubusercontent.com/microsoft/pyright/main/packages/pyright/schema/pyrightconfig.schema.json",
  "include": ["src"],
  "exclude": [
    "**/node_modules",
    "**/__pycache__",
    ".venv",
    "venv",
    "build",
    "dist",
    "tests"
  ],
  "pythonVersion": "3.11",
  "typeCheckingMode": "strict",
  "executionEnvironments": [
    {
      "root": "src",
      "extraPaths": ["./src"]
    }
  ],
  "reportMissingImports": true,
  "reportMissingTypeStubs": false,
  "reportOptionalMemberAccess": "warning",
  "reportOptionalSubscript": "warning",
  "reportGeneralTypeIssues": "error",
  "reportUnknownArgumentType": "none"
}
```

## Auto-Generated Configurations

### .pylintrc

Generated automatically during installation:

```ini
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
```

### .flake8

Generated automatically during installation:

```ini
[flake8]
exclude = .venv,venv,build,dist,.mypy_cache,.pytest_cache,.idea,.git
max-line-length = 120
extend-ignore = E203
select = B, E, F, W, B9
```

## Customizing Configurations

### Override Default Settings

Create custom configuration files in your project root:

**Custom .pylintrc:**
```ini
[MASTER]
ignore=venv,.venv,build,dist,.mypy_cache,.pytest_cache,.idea,.git,tests

[MESSAGES CONTROL]
disable=C0114,C0115,C0116,C0103  ; ignore missing docstrings and invalid names

[FORMAT]
max-line-length=100
```

**Custom .flake8:**
```ini
[flake8]
exclude = .venv,venv,build,dist,.mypy_cache,.pytest_cache,.idea,.git,tests
max-line-length = 100
extend-ignore = E203,W503
select = B, E, F, W, B9
```

### Project-Specific Configurations

**For Django projects:**
```toml
[tool.pylint]
load-plugins = ["pylint_django"]

[tool.pylint."MESSAGES CONTROL"]
disable = ["C0114", "C0115", "C0116", "C0103", "R0903", "R0904"]
```

**For FastAPI projects:**
```toml
[tool.mypy]
plugins = ["pydantic.mypy"]

[tool.pylint."MESSAGES CONTROL"]
disable = ["C0114", "C0115", "C0116"]
```

**For Data Science projects:**
```toml
[tool.pylint."MESSAGES CONTROL"]
disable = ["C0114", "C0115", "C0116", "R0903", "R0904", "W0613"]

[tool.isort]
known_first_party = ["src", "notebooks"]
known_third_party = ["numpy", "pandas", "matplotlib", "seaborn", "sklearn"]
```

## Environment-Specific Configurations

### Development Environment

```toml
[tool.pylint."MESSAGES CONTROL"]
disable = ["C0114", "C0115", "C0116"]  # Allow missing docstrings in dev

[tool.mypy]
warn_return_any = false
warn_unused_configs = false
```

### Production Environment

```toml
[tool.pylint."MESSAGES CONTROL"]
disable = []  # Enable all checks

[tool.mypy]
strict = true
warn_return_any = true
warn_unused_configs = true
```

## IDE Integration

### VS Code Settings

**settings.json:**
```json
{
    "python.linting.pylintEnabled": true,
    "python.linting.pylintArgs": ["--rcfile=.pylintrc"],
    "python.linting.flake8Enabled": true,
    "python.linting.flake8Args": ["--config=.flake8"],
    "python.linting.banditEnabled": true,
    "python.linting.mypyEnabled": true,
    "python.linting.mypyArgs": ["--config-file=pyproject.toml"],
    "python.formatting.provider": "black",
    "python.sortImports.args": ["--profile", "black"]
}
```

### PyCharm Settings

1. Go to Settings → Tools → External Tools
2. Add new tool with:
   - Name: Lint Heroes
   - Program: `lint-heroes`
   - Arguments: `$FilePath$`
   - Working directory: `$ProjectFileDir$`

## Configuration Validation

### Check Configuration Syntax

```bash
# Validate pyproject.toml
python -c "import tomllib; tomllib.load(open('pyproject.toml', 'rb'))"

# Validate bandit.yaml
bandit --config bandit.yaml --help

# Validate pyrightconfig.json
pyright --project pyrightconfig.json --help
```

### Test Configuration

```bash
# Test pylint configuration
pylint --rcfile=.pylintrc --help

# Test flake8 configuration
flake8 --config=.flake8 --help

# Test mypy configuration
mypy --config-file=pyproject.toml --help
```

## Troubleshooting Configuration

### Common Issues

1. **Configuration not found:**
   ```bash
   # Check if files exist
   ls -la .pylintrc .flake8 pyproject.toml bandit.yaml
   ```

2. **Invalid configuration syntax:**
   ```bash
   # Validate TOML syntax
   python -c "import tomllib; print('Valid TOML')" < pyproject.toml
   ```

3. **Conflicting configurations:**
   ```bash
   # Check for multiple config files
   find . -name ".pylintrc" -o -name ".flake8" -o -name "setup.cfg"
   ```

### Reset to Defaults

```bash
# Remove custom configurations
rm -f .pylintrc .flake8

# Reinstall to regenerate defaults
./macos/installall.sh
```
