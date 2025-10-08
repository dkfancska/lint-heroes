# Test script to diagnose Python version detection issues
Write-Host "=== Python Version Detection Test ===" -ForegroundColor Yellow

# Test different Python commands
$PythonCommands = @("python", "python3", "python3.11", "python3.12", "python3.10", "python3.9")

foreach ($cmd in $PythonCommands) {
    Write-Host "`nTesting: $cmd" -ForegroundColor Cyan
    try {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            $location = (Get-Command $cmd).Source
            Write-Host "  Location: $location" -ForegroundColor Green
            
            # Test --version output
            $version = & $cmd --version 2>&1
            Write-Host "  --version output: $version" -ForegroundColor Green
            
            # Test sys.version_info (most reliable)
            $sysVersion = & $cmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')" 2>$null
            Write-Host "  sys.version_info: $sysVersion" -ForegroundColor Green
            
            # Test version check
            $versionCheck = & $cmd -c "import sys; print('OK' if sys.version_info >= (3, 9) else 'OLD')" 2>$null
            Write-Host "  Version >= 3.9: $versionCheck" -ForegroundColor Green
            
            # Test if it's Microsoft Store Python
            if ($location -like "*WindowsApps*") {
                Write-Host "  ⚠ Microsoft Store Python detected" -ForegroundColor Yellow
                Write-Host "  This may cause issues with some tools" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  Command not found" -ForegroundColor Red
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Recommendations ===" -ForegroundColor Yellow
Write-Host "If you're using Microsoft Store Python and having issues:" -ForegroundColor Cyan
Write-Host "1. Consider installing Python from python.org instead" -ForegroundColor White
Write-Host "2. Or use pyenv-win for better Python version management" -ForegroundColor White
Write-Host "3. Or use conda/miniconda for Python environment management" -ForegroundColor White

Write-Host "`n=== Test Complete ===" -ForegroundColor Yellow
