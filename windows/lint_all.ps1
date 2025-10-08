# PowerShell script for linting
param(
    [string]$Target = "."
)

# Use local venv if exists
if (Test-Path ".venv") {
    & ".venv\Scripts\Activate.ps1"
}

$isDir = Test-Path $Target -PathType Container

Write-Host "▶ Linting target: $Target" -ForegroundColor Green

$status = 0

function Run-Linter {
    param([string]$Name, [string]$Command, [string[]]$Arguments)
    
    Write-Host ""
    Write-Host "---- $Name ----" -ForegroundColor Cyan
    
    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        try {
            & $Command @Arguments
            if ($LASTEXITCODE -ne 0) {
                $script:status = 1
            }
        } catch {
            Write-Host "Error running $Name" -ForegroundColor Red
            $script:status = 1
        }
    } else {
        Write-Host "⚠ $Name not found (skipping)" -ForegroundColor Yellow
    }
}

# Pylint
Run-Linter "pylint" "pylint" @($Target)

# flake8 + bugbear  
Run-Linter "flake8" "flake8" @($Target)

# bandit
if ($isDir) {
    Run-Linter "bandit" "bandit" @("-q", "-r", $Target)
} else {
    Run-Linter "bandit" "bandit" @("-q", $Target)
}

# type check: prefer pyright, else mypy
if (Get-Command pyright -ErrorAction SilentlyContinue) {
    Run-Linter "pyright" "pyright" @($Target)
} elseif (Get-Command mypy -ErrorAction SilentlyContinue) {
    Run-Linter "mypy" "mypy" @($Target)
} else {
    Write-Host "⚠ Neither pyright nor mypy found (skipping type checks)" -ForegroundColor Yellow
}

Write-Host ""
if ($status -ne 0) {
    Write-Host "❌ Linting found issues." -ForegroundColor Red
} else {
    Write-Host "✅ Linting passed." -ForegroundColor Green
}

exit $status
