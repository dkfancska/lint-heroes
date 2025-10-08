# PowerShell script for Windows
param(
    [string]$PythonPath = "python"
)

Write-Host "▶ Detecting Python..." -ForegroundColor Green

# Find all available Python versions
$PythonVersions = @("python3.11", "python3.12", "python3.13", "python3.10", "python3.9", "python3", "python")
$AvailablePythons = @()

foreach ($version in $PythonVersions) {
    if (Get-Command $version -ErrorAction SilentlyContinue) {
        $AvailablePythons += $version
    }
}

if ($AvailablePythons.Count -eq 0) {
    Write-Host "❌ No Python versions found. Install Python 3.9+ first." -ForegroundColor Red
    exit 1
}

# If PythonPath is specified via parameter, use it
if ($PythonPath -and (Get-Command $PythonPath -ErrorAction SilentlyContinue)) {
    Write-Host "✔ Using specified Python: $PythonPath" -ForegroundColor Green
} else {
    # Interactive selection
    Write-Host "Available Python versions:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $AvailablePythons.Count; $i++) {
        $version = $AvailablePythons[$i]
        try {
            $pyVersion = & $version --version 2>&1 | Select-String -Pattern '\d+\.\d+' | ForEach-Object { $_.Matches[0].Value }
            $location = (Get-Command $version).Source
            Write-Host "  $($i+1). $version (Python $pyVersion) at $location" -ForegroundColor White
        } catch {
            Write-Host "  $($i+1). $version (version unknown)" -ForegroundColor White
        }
    }
    
    Write-Host ""
    $choice = Read-Host "Select Python version for linting tools (1-$($AvailablePythons.Count)) or press Enter for default (1)"
    
    # Default to first option if no input
    if ([string]::IsNullOrEmpty($choice)) { $choice = "1" }
    
    # Validate choice
    if (-not ($choice -match '^\d+$') -or [int]$choice -lt 1 -or [int]$choice -gt $AvailablePythons.Count) {
        Write-Host "❌ Invalid selection. Using default: $($AvailablePythons[0])" -ForegroundColor Yellow
        $choice = "1"
    }
    
    $PythonPath = $AvailablePythons[[int]$choice - 1]
}

# Check Python version
try {
    $PythonVersion = & $PythonPath --version 2>&1 | Select-String -Pattern '\d+\.\d+' | ForEach-Object { $_.Matches[0].Value }
    $PythonLocation = (Get-Command $PythonPath).Source
    Write-Host "✔ Selected Python $PythonVersion at: $PythonLocation" -ForegroundColor Green
    
    # Check if version is 3.9+ (minimum requirement)
    $VersionCheck = & $PythonPath -c "import sys; print('OK' if sys.version_info >= (3, 9) else 'OLD')" 2>$null
    if ($VersionCheck -ne "OK") {
        Write-Host "❌ Python $PythonVersion is too old. Python 3.9+ is required." -ForegroundColor Red
        exit 1
    }
    
    # Warn about older versions
    $VersionCheck = & $PythonPath -c "import sys; print('OK' if sys.version_info >= (3, 11) else 'OLD')" 2>$null
    if ($VersionCheck -ne "OK") {
        Write-Host "⚠ Warning: Python $PythonVersion found, but Python 3.11+ is recommended for best compatibility" -ForegroundColor Yellow
        Write-Host "  Consider using a newer Python version if available" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error checking Python version: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "▶ Creating virtualenv .venv (if missing)..." -ForegroundColor Green
if (-not (Test-Path ".venv")) {
    & $PythonPath -m venv .venv
}

Write-Host "▶ Activating virtual environment..." -ForegroundColor Green
& ".venv\Scripts\Activate.ps1"

Write-Host "▶ Upgrading pip..." -ForegroundColor Green
pip install -U pip

Write-Host "▶ Installing linters into .venv..." -ForegroundColor Green
pip install -U @(
    "pylint",
    "flake8",
    "flake8-bugbear", 
    "bandit",
    "mypy"
)

Write-Host "▶ Installing pyright via npm (if available)..." -ForegroundColor Green
if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "▶ Installing pyright via npm..." -ForegroundColor Green
    npm install -g pyright
} else {
    Write-Host "⚠ npm not found. Skipping pyright install." -ForegroundColor Yellow
    Write-Host "  You can install it manually: npm install -g pyright" -ForegroundColor Yellow
}

Write-Host "▶ Copying config files (won't overwrite existing)..." -ForegroundColor Green

# Copy config files from windows/ directory to project root
if (-not (Test-Path ".pylintrc")) {
    if (Test-Path "windows\.pylintrc") {
        Copy-Item "windows\.pylintrc" ".pylintrc"
    } else {
        # Create default .pylintrc if not found
        @"
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
"@ | Out-File -FilePath ".pylintrc" -Encoding UTF8
    }
}

if (-not (Test-Path ".flake8")) {
    if (Test-Path "windows\.flake8") {
        Copy-Item "windows\.flake8" ".flake8"
    } else {
        # Create default .flake8 if not found
        @"
[flake8]
exclude = .venv,venv,build,dist,.mypy_cache,.pytest_cache,.idea,.git
max-line-length = 120
extend-ignore = E203
select = B, E, F, W, B9
"@ | Out-File -FilePath ".flake8" -Encoding UTF8
    }
}

# Copy other config files if they don't exist
if (-not (Test-Path "pyproject.toml")) {
    if (Test-Path "windows\pyproject.toml") {
        Copy-Item "windows\pyproject.toml" "pyproject.toml"
    }
}

if (-not (Test-Path "bandit.yaml")) {
    if (Test-Path "windows\bandit.yaml") {
        Copy-Item "windows\bandit.yaml" "bandit.yaml"
    }
}

if (-not (Test-Path "pyrightconfig.json")) {
    if (Test-Path "windows\pyrightconfig.json") {
        Copy-Item "windows\pyrightconfig.json" "pyrightconfig.json"
    }
}

Write-Host "▶ Creating aliases for easy access..." -ForegroundColor Green

# Create PowerShell profile if it doesn't exist
$ProfilePath = $PROFILE.CurrentUserAllHosts
$ProfileDir = Split-Path $ProfilePath -Parent

if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

# Create aliases in PowerShell profile
$AliasContent = @"

# Lint Heroes aliases
function lint-heroes {
    param([string]`$Target = ".")
    & "$PWD\windows\lint_all.ps1" `$Target
}

function lint-install {
    & "$PWD\windows\installall.ps1"
}

function lint-install-multiple {
    & "$PWD\windows\install_multiple.ps1"
}

function lint {
    param([string]`$Target = ".")
    lint-heroes `$Target
}

function lint-multi {
    lint-install-multiple
}

# Export functions
Export-ModuleMember -Function lint-heroes, lint-install, lint-install-multiple, lint, lint-multi
"@

# Check if aliases already exist
if (-not (Test-Path $ProfilePath) -or -not (Get-Content $ProfilePath -Raw | Select-String "lint-heroes")) {
    Add-Content -Path $ProfilePath -Value $AliasContent
    Write-Host "✔ Aliases added to PowerShell profile: $ProfilePath" -ForegroundColor Green
    Write-Host "  - lint-heroes: run linting" -ForegroundColor White
    Write-Host "  - lint-install: reinstall linters for current Python" -ForegroundColor White
    Write-Host "  - lint-install-multiple: install for multiple Python versions" -ForegroundColor White
    Write-Host "  - lint: shortcut for lint-heroes" -ForegroundColor White
    Write-Host "  - lint-multi: shortcut for lint-install-multiple" -ForegroundColor White
    Write-Host "  Run 'Import-Module $ProfilePath' or restart PowerShell to use aliases" -ForegroundColor Yellow
} else {
    Write-Host "✔ Aliases already exist in PowerShell profile" -ForegroundColor Green
}

Write-Host "▶ Creating lint_all.ps1..." -ForegroundColor Green
@"
# PowerShell script for linting
param(
    [string]`$Target = "."
)

# Use local venv if exists
if (Test-Path ".venv") {
    & ".venv\Scripts\Activate.ps1"
}

`$isDir = Test-Path `$Target -PathType Container

Write-Host "▶ Linting target: `$Target" -ForegroundColor Green

`$status = 0

function Run-Linter {
    param([string]`$Name, [string]`$Command, [string[]]`$Arguments)
    
    Write-Host ""
    Write-Host "---- `$Name ----" -ForegroundColor Cyan
    
    if (Get-Command `$Command -ErrorAction SilentlyContinue) {
        try {
            & `$Command @Arguments
            if (`$LASTEXITCODE -ne 0) {
                `$script:status = 1
            }
        } catch {
            Write-Host "Error running `$Name" -ForegroundColor Red
            `$script:status = 1
        }
    } else {
        Write-Host "⚠ `$Name not found (skipping)" -ForegroundColor Yellow
    }
}

# Pylint
Run-Linter "pylint" "pylint" @(`$Target)

# flake8 + bugbear  
Run-Linter "flake8" "flake8" @(`$Target)

# bandit
if (`$isDir) {
    Run-Linter "bandit" "bandit" @("-q", "-r", `$Target)
} else {
    Run-Linter "bandit" "bandit" @("-q", `$Target)
}

# type check: prefer pyright, else mypy
if (Get-Command pyright -ErrorAction SilentlyContinue) {
    Run-Linter "pyright" "pyright" @(`$Target)
} elseif (Get-Command mypy -ErrorAction SilentlyContinue) {
    Run-Linter "mypy" "mypy" @(`$Target)
} else {
    Write-Host "⚠ Neither pyright nor mypy found (skipping type checks)" -ForegroundColor Yellow
}

Write-Host ""
if (`$status -ne 0) {
    Write-Host "❌ Linting found issues." -ForegroundColor Red
} else {
    Write-Host "✅ Linting passed." -ForegroundColor Green
}

exit `$status
"@ | Out-File -FilePath "lint_all.ps1" -Encoding UTF8

Write-Host "▶ Adding PyCharm Run configuration for Windows..." -ForegroundColor Green
if (-not (Test-Path ".run")) {
    New-Item -ItemType Directory -Path ".run" | Out-Null
}

@"
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Lint All PowerShell" type="PowerShellConfigurationType">
    <option name="SCRIPT_PATH" value="$PROJECT_DIR$/lint_all.ps1" />
    <option name="SCRIPT_OPTIONS" value="" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="WORKING_DIRECTORY" value="$PROJECT_DIR$" />
    <option name="EXECUTE_IN_TERMINAL" value="true" />
    <method v="2" />
  </configuration>
</component>
"@ | Out-File -FilePath ".run\Lint All PowerShell.run.xml" -Encoding UTF8

Write-Host ""
Write-Host "▶ Done." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1) Run installall.ps1" -ForegroundColor White
Write-Host "  2) In PyCharm: select Run configuration 'Lint All PowerShell' and Run" -ForegroundColor White
Write-Host "  3) To lint a single file: run '.\lint_all.ps1 path\to\file.py' from PowerShell" -ForegroundColor White
Write-Host "     or edit Run configuration and add '%FilePath%' to SCRIPT_OPTIONS." -ForegroundColor White
