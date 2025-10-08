# PowerShell script for Windows with Microsoft Store Python support
param(
    [string]$PythonPath = "python"
)

Write-Host "=== Lint Heroes Installation (Microsoft Store Python) ===" -ForegroundColor Yellow
Write-Host "This script is optimized for Microsoft Store Python installations" -ForegroundColor Cyan

# Check if Python is available
if (-not (Get-Command $PythonPath -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python not found. Please install Python from python.org or Microsoft Store" -ForegroundColor Red
    exit 1
}

$PythonLocation = (Get-Command $PythonPath).Source
Write-Host "✔ Using Python at: $PythonLocation" -ForegroundColor Green

# Check if it's Microsoft Store Python
if ($PythonLocation -like "*WindowsApps*") {
    Write-Host "⚠ Microsoft Store Python detected" -ForegroundColor Yellow
    Write-Host "  This may cause some compatibility issues" -ForegroundColor Yellow
    Write-Host "  Consider installing Python from python.org for better compatibility" -ForegroundColor Yellow
}

# Get Python version using sys module (most reliable for MS Store Python)
try {
    $PythonVersion = & $PythonPath -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
    if (-not $PythonVersion) {
        Write-Host "❌ Cannot determine Python version" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✔ Detected Python version: $PythonVersion" -ForegroundColor Green
    
    # Check if version is 3.9+ (minimum requirement)
    $VersionCheck = & $PythonPath -c "import sys; print('OK' if sys.version_info >= (3, 9) else 'OLD')" 2>$null
    if ($VersionCheck -ne "OK") {
        Write-Host "❌ Python $PythonVersion is too old. Python 3.9+ is required." -ForegroundColor Red
        Write-Host "  Detected version: $PythonVersion" -ForegroundColor Red
        Write-Host "  Required: 3.9 or higher" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✔ Python version $PythonVersion is compatible" -ForegroundColor Green
} catch {
    Write-Host "❌ Error checking Python version: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "▶ Creating virtualenv .venv (if missing)..." -ForegroundColor Green
if (-not (Test-Path ".venv")) {
    try {
        & $PythonPath -m venv .venv
        Write-Host "✔ Virtual environment created" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to create virtual environment: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Try running: $PythonPath -m venv .venv" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "▶ Activating virtual environment..." -ForegroundColor Green
& .venv\Scripts\Activate.ps1

Write-Host "▶ Installing linting tools..." -ForegroundColor Green
try {
    # Install from requirements
    if (Test-Path "req.txt") {
        pip install -r req.txt
    } else {
        # Install individual tools
        pip install pylint flake8 bandit mypy isort
    }
    
    # Install pyright via pip (no Node.js needed)
    Write-Host "▶ Installing pyright (fast type checker)..." -ForegroundColor Green
    pip install pyright
    
    Write-Host "✔ All tools installed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install tools: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Try running: pip install -r req.txt" -ForegroundColor Yellow
    exit 1
}

Write-Host "▶ Setting up aliases..." -ForegroundColor Green
# Create PowerShell functions
$ProfilePath = $PROFILE
if (-not (Test-Path $ProfilePath)) {
    New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
}

# Add functions to profile
$Functions = @"
function lint-heroes {
    param([string]`$Target = ".")
    & "`$PSScriptRoot\lint_all.ps1" `$Target
}

function lint-install {
    & "`$PSScriptRoot\windows\installall_msstore.ps1"
}

function lint-install-multiple {
    & "`$PSScriptRoot\windows\install_multiple.ps1"
}

function lint {
    lint-heroes `$Target
}

function lint-multi {
    lint-install-multiple
}

Export-ModuleMember -Function lint-heroes, lint-install, lint-install-multiple, lint, lint-multi
"@

if (-not (Get-Content $ProfilePath -Raw | Select-String "lint-heroes")) {
    Add-Content -Path $ProfilePath -Value "`n# Lint Heroes aliases`n$Functions"
    Write-Host "✔ PowerShell aliases added to profile" -ForegroundColor Green
    Write-Host "  Available commands:" -ForegroundColor White
    Write-Host "  - lint-heroes: run linting" -ForegroundColor White
    Write-Host "  - lint-install: reinstall linters" -ForegroundColor White
    Write-Host "  - lint-install-multiple: install for multiple Python versions" -ForegroundColor White
    Write-Host "  - lint: shortcut for lint-heroes" -ForegroundColor White
    Write-Host "  - lint-multi: shortcut for lint-install-multiple" -ForegroundColor White
} else {
    Write-Host "✔ PowerShell aliases already exist" -ForegroundColor Green
}

Write-Host "`n=== Installation Complete ===" -ForegroundColor Green
Write-Host "You can now use:" -ForegroundColor Cyan
Write-Host "  lint-heroes your_file.py" -ForegroundColor White
Write-Host "  lint-heroes src/" -ForegroundColor White
Write-Host "  lint-heroes" -ForegroundColor White
Write-Host "`nNote: If you encounter issues with Microsoft Store Python," -ForegroundColor Yellow
Write-Host "consider installing Python from python.org for better compatibility." -ForegroundColor Yellow
