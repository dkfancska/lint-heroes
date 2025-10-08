# Test script to diagnose Python version detection issues
Write-Host "=== Python Version Detection Test ===" -ForegroundColor Yellow

# Test different Python commands
$PythonCommands = @("python", "python3", "python3.11", "python3.12", "python3.10", "python3.9")

foreach ($cmd in $PythonCommands) {
    Write-Host "`nTesting: $cmd" -ForegroundColor Cyan
    try {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            $version = & $cmd --version 2>&1
            Write-Host "  Version output: $version" -ForegroundColor Green
            
            # Test sys.version_info
            $sysVersion = & $cmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')" 2>$null
            Write-Host "  sys.version_info: $sysVersion" -ForegroundColor Green
            
            # Test version check
            $versionCheck = & $cmd -c "import sys; print('OK' if sys.version_info >= (3, 9) else 'OLD')" 2>$null
            Write-Host "  Version >= 3.9: $versionCheck" -ForegroundColor Green
            
            # Test location
            $location = (Get-Command $cmd).Source
            Write-Host "  Location: $location" -ForegroundColor Green
        } else {
            Write-Host "  Command not found" -ForegroundColor Red
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Yellow
