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
if (Test-Path ".pylintrc") {
    Run-Linter "pylint" "pylint" @("--rcfile=.pylintrc", $Target)
} elseif (Test-Path "windows\.pylintrc") {
    Run-Linter "pylint" "pylint" @("--rcfile=windows\.pylintrc", $Target)
} else {
    Run-Linter "pylint" "pylint" @($Target)
}

# flake8 + bugbear  
if (Test-Path ".flake8") {
    Run-Linter "flake8" "flake8" @("--config=.flake8", $Target)
} elseif (Test-Path "windows\.flake8") {
    Run-Linter "flake8" "flake8" @("--config=windows\.flake8", $Target)
} else {
    Run-Linter "flake8" "flake8" @($Target)
}

# bandit
if (Test-Path "bandit.yaml") {
    if ($isDir) {
        Run-Linter "bandit" "bandit" @("-q", "-r", "-c", "bandit.yaml", $Target)
    } else {
        Run-Linter "bandit" "bandit" @("-q", "-c", "bandit.yaml", $Target)
    }
} elseif (Test-Path "windows\bandit.yaml") {
    if ($isDir) {
        Run-Linter "bandit" "bandit" @("-q", "-r", "-c", "windows\bandit.yaml", $Target)
    } else {
        Run-Linter "bandit" "bandit" @("-q", "-c", "windows\bandit.yaml", $Target)
    }
} else {
    if ($isDir) {
        Run-Linter "bandit" "bandit" @("-q", "-r", $Target)
    } else {
        Run-Linter "bandit" "bandit" @("-q", $Target)
    }
}

# type check: prefer pyright, else mypy
if (Get-Command pyright -ErrorAction SilentlyContinue) {
    if (Test-Path "pyrightconfig.json") {
        Run-Linter "pyright" "pyright" @($Target)
    } elseif (Test-Path "windows\pyrightconfig.json") {
        Copy-Item "windows\pyrightconfig.json" "pyrightconfig.json" -Force
        Run-Linter "pyright" "pyright" @($Target)
        Remove-Item "pyrightconfig.json" -Force -ErrorAction SilentlyContinue
    } else {
        Run-Linter "pyright" "pyright" @($Target)
    }
} elseif (Get-Command mypy -ErrorAction SilentlyContinue) {
    if (Test-Path "pyproject.toml") {
        Run-Linter "mypy" "mypy" @("--config-file", "pyproject.toml", $Target)
    } elseif (Test-Path "windows\pyproject.toml") {
        Run-Linter "mypy" "mypy" @("--config-file", "windows\pyproject.toml", $Target)
    } else {
        Run-Linter "mypy" "mypy" @($Target)
    }
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
