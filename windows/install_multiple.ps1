# PowerShell script for installing linting tools for multiple Python versions
param(
    [string[]]$PythonVersions = @()
)

Write-Host "🐍 Lint Heroes - Multiple Python Versions Installer" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Find all available Python versions
$AvailablePythons = @()
$PythonVersionsToCheck = @("python3.11", "python3.12", "python3.13", "python3.10", "python3.9", "python3", "python")

foreach ($version in $PythonVersionsToCheck) {
    if (Get-Command $version -ErrorAction SilentlyContinue) {
        $AvailablePythons += $version
    }
}

if ($AvailablePythons.Count -eq 0) {
    Write-Host "❌ No Python versions found. Install Python 3.9+ first." -ForegroundColor Red
    exit 1
}

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
Write-Host "Select Python versions to install linting tools for:" -ForegroundColor Yellow
Write-Host "Enter numbers separated by spaces (e.g., 1 3 5) or 'all' for all versions:" -ForegroundColor Yellow
$choices = Read-Host "Your choice"

# Parse choices
$SelectedPythons = @()
if ($choices -eq "all") {
    $SelectedPythons = $AvailablePythons
} else {
    $choiceNumbers = $choices -split '\s+'
    foreach ($choice in $choiceNumbers) {
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $AvailablePythons.Count) {
            $SelectedPythons += $AvailablePythons[[int]$choice - 1]
        } else {
            Write-Host "⚠ Invalid choice: $choice (skipping)" -ForegroundColor Yellow
        }
    }
}

if ($SelectedPythons.Count -eq 0) {
    Write-Host "❌ No valid Python versions selected." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Selected Python versions:" -ForegroundColor Green
foreach ($version in $SelectedPythons) {
    try {
        $pyVersion = & $version --version 2>&1 | Select-String -Pattern '\d+\.\d+' | ForEach-Object { $_.Matches[0].Value }
        Write-Host "  - $version (Python $pyVersion)" -ForegroundColor White
    } catch {
        Write-Host "  - $version (version unknown)" -ForegroundColor White
    }
}

Write-Host ""
$continue = Read-Host "Continue with installation? (y/N)"
if ($continue -notmatch "^[Yy]$") {
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    exit 0
}

# Install for each selected Python version
foreach ($pyBin in $SelectedPythons) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Installing for $pyBin" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    
    # Create version-specific virtual environment
    $venvName = ".venv-$($pyBin -replace 'python', '')"
    Write-Host "▶ Creating virtualenv $venvName..." -ForegroundColor Green
    & $pyBin -m venv $venvName
    
    # Activate virtual environment
    $activateScript = "$venvName\Scripts\Activate.ps1"
    & $activateScript
    
    # Upgrade pip
    Write-Host "▶ Upgrading pip..." -ForegroundColor Green
    pip install -U pip
    
    # Install linters
    Write-Host "▶ Installing linters..." -ForegroundColor Green
    pip install -U @(
        "pylint",
        "flake8",
        "flake8-bugbear", 
        "bandit",
        "mypy",
        "isort"
    )
    
    # Install pyright if available
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "▶ Installing pyright..." -ForegroundColor Green
        npm install -g pyright
    }
    
    # Deactivate virtual environment
    deactivate
    
    Write-Host "✅ Installation completed for $pyBin" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Installation completed for all selected Python versions!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Yellow
foreach ($pyBin in $SelectedPythons) {
    $venvName = ".venv-$($pyBin -replace 'python', '')"
    Write-Host "  # For $pyBin:" -ForegroundColor White
    Write-Host "  & `"$venvName\Scripts\Activate.ps1`"" -ForegroundColor White
    Write-Host "  pylint your_file.py" -ForegroundColor White
    Write-Host "  deactivate" -ForegroundColor White
    Write-Host ""
}
