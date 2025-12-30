# Check for P4wnP1 A.L.O.A. Development Requirements

Write-Host "Checking environment for P4wnP1 A.L.O.A. dependencies..." -ForegroundColor Cyan
Write-Host "--------------------------------------------------------"

$missing = $false

# Check Go
try {
    $goVersion = go version
    Write-Host "[OK] Go is installed: $goVersion" -ForegroundColor Green
} catch {
    Write-Host "[MISSING] Go (Golang) is not found." -ForegroundColor Red
    Write-Host "    -> Install from: https://go.dev/dl/" -ForegroundColor Gray
    $missing = $true
}

# Check Node
try {
    $nodeVersion = node --version
    Write-Host "[OK] Node.js is installed: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "[MISSING] Node.js is not found." -ForegroundColor Red
    Write-Host "    -> Install from: https://nodejs.org/" -ForegroundColor Gray
    $missing = $true
}

# Check Python
try {
    $pyVersion = python --version 2>&1
    Write-Host "[OK] Python is installed: $pyVersion" -ForegroundColor Green
} catch {
    Write-Host "[MISSING] Python is not found." -ForegroundColor Red
    Write-Host "    -> Install from: https://www.python.org/downloads/windows/" -ForegroundColor Gray
    $missing = $true
}

Write-Host "--------------------------------------------------------"

if ($missing) {
    Write-Host "Some dependencies are missing. Please install them to build the client tools." -ForegroundColor Yellow
} else {
    Write-Host "All dependencies found! You can build the CLI client now." -ForegroundColor Green
    Write-Host "Run: go build -o P4wnP1_cli.exe ./cmd/P4wnP1_cli" -ForegroundColor Cyan
}
