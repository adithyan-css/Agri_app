<#
.SYNOPSIS
  One-click launcher for AgriPrice AI - starts all services and runs the Flutter app.
.USAGE
  .\start.ps1              # auto-detect Android device
  .\start.ps1 -Device chrome   # run on Chrome
  .\start.ps1 -SkipFlutter     # start services only
#>
param(
    [string]$Device,
    [switch]$SkipFlutter
)

$ErrorActionPreference = 'Continue'
$Root = $PSScriptRoot
$ADB  = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

function Write-Step($msg) { Write-Host "`n>> $msg" -ForegroundColor Cyan }

# ── 1. Docker Desktop ────────────────────────────────────
Write-Step "Ensuring Docker Desktop is running..."
$docker = Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue
if (-not $docker) {
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Write-Host "   Waiting for Docker daemon..."
    $tries = 0
    while ($tries -lt 30) {
        Start-Sleep -Seconds 3
        $tries++
        try { docker info 2>$null | Out-Null; break } catch {}
    }
    if ($tries -ge 30) { Write-Host "   Docker failed to start!" -ForegroundColor Red; exit 1 }
}
Write-Host "   Docker is ready." -ForegroundColor Green

# ── 2. Docker containers (DB, Redis, ML) ─────────────────
Write-Step "Starting Docker containers (db, redis, ml-service)..."
Push-Location $Root
docker compose up -d db redis ml-service 2>&1 | Out-Host
Pop-Location

# Wait for DB to be healthy
Write-Host "   Waiting for PostgreSQL to be healthy..."
$dbReady = $false
for ($i = 0; $i -lt 20; $i++) {
    $status = docker inspect --format '{{.State.Health.Status}}' agriprice-db 2>$null
    if ($status -eq 'healthy') { $dbReady = $true; break }
    Start-Sleep -Seconds 2
}
if ($dbReady) { Write-Host "   PostgreSQL is healthy." -ForegroundColor Green }
else          { Write-Host "   PostgreSQL may not be ready yet - continuing anyway." -ForegroundColor Yellow }

# Wait for ML service
Write-Host "   Waiting for ML service..."
$mlReady = $false
for ($i = 0; $i -lt 15; $i++) {
    try {
        $r = Invoke-WebRequest -Uri "http://127.0.0.1:8000/" -UseBasicParsing -TimeoutSec 2
        if ($r.StatusCode -eq 200) { $mlReady = $true; break }
    } catch {}
    Start-Sleep -Seconds 2
}
if ($mlReady) { Write-Host "   ML service is ready." -ForegroundColor Green }
else          { Write-Host "   ML service may not be ready yet - continuing anyway." -ForegroundColor Yellow }

# ── 3. NestJS Backend (local, not Docker) ─────────────────
Write-Step "Starting NestJS backend on port 3000..."
# Kill any existing node process on port 3000
$existing = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique
foreach ($pid in $existing) {
    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
    if ($proc.ProcessName -eq 'node') {
        Stop-Process -Id $pid -Force
        Write-Host "   Killed old node process (PID $pid)"
    }
}
# Stop the Docker backend container if running (we run locally instead)
docker stop agriprice-backend 2>$null | Out-Null

# Start backend in background
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:Root\backend
    & npx nest start 2>&1
}
Write-Host "   Backend starting in background (Job $($backendJob.Id))..."

# Wait for backend to be listening
$beReady = $false
for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Seconds 2
    $listening = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue |
        Where-Object { $_.State -eq 'Listen' }
    if ($listening) { $beReady = $true; break }
}
if ($beReady) { Write-Host "   Backend is listening on :3000" -ForegroundColor Green }
else          { Write-Host "   Backend may still be starting..." -ForegroundColor Yellow }

# ── 4. ADB reverse ports ─────────────────────────────────
Write-Step "Setting up ADB reverse ports..."
if (Test-Path $ADB) {
    $devices = & $ADB devices 2>$null | Select-String "device$"
    if ($devices) {
        & $ADB reverse tcp:3000 tcp:3000 | Out-Null
        & $ADB reverse tcp:8000 tcp:8000 | Out-Null
        Write-Host "   ADB reverse: 3000 -> 3000, 8000 -> 8000" -ForegroundColor Green
    } else {
        Write-Host "   No Android device connected - skipping ADB reverse." -ForegroundColor Yellow
    }
} else {
    Write-Host "   ADB not found at $ADB - skipping." -ForegroundColor Yellow
}

# ── 5. Flutter ────────────────────────────────────────────
if ($SkipFlutter) {
    Write-Host "`nAll services started. Skipping Flutter (use -SkipFlutter to change)." -ForegroundColor Green
    Write-Host "Backend job ID: $($backendJob.Id)  (Stop-Job $($backendJob.Id) to stop)"
    return
}

Write-Step "Running Flutter app..."
Push-Location "$Root\mobile"
flutter pub get | Out-Host

if ($Device) {
    flutter run -d $Device
} else {
    # Auto-detect: prefer a connected Android device, else use first available
    $androidDev = & $ADB devices 2>$null | Select-String "device$" | Select-Object -First 1
    if ($androidDev) {
        $devId = ($androidDev -split '\s+')[0]
        Write-Host "   Detected Android device: $devId" -ForegroundColor Green
        flutter run -d $devId
    } else {
        Write-Host "   No Android device - running on default device..." -ForegroundColor Yellow
        flutter run
    }
}
Pop-Location
