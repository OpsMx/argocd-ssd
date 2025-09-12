param(
    [string]$Version = "v2025.08.45"
)
Write-Host "🚀 Installing SSD Scanner CLI $Version for Windows..." -ForegroundColor Green
# Step 1: Create directories
Write-Host "`n📁 Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "C:\Tools\ssd-scanner" | Out-Null
New-Item -ItemType Directory -Force -Path "C:\.local\bin" | Out-Null
# Step 2: Download main CLI
Write-Host "`n⬇️ Downloading main SSD Scanner CLI..." -ForegroundColor Yellow
$mainCliUrl = "https://github.com/OpsMx/ssd-scanner-cli-public/releases/download/$Version/ssd-scanner-cli-windows-amd64.exe"
try {
    Invoke-WebRequest -Uri $mainCliUrl -OutFile "C:\Tools\ssd-scanner\ssd-scanner-cli.exe"
    Write-Host "   ✅ Main CLI downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to download main CLI: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
# Step 3: Download embedded Syft binary
Write-Host "`n⬇️ Downloading embedded Syft binary..." -ForegroundColor Yellow
$syftEmbedUrl = "https://github.com/OpsMx/ssd-scanner-cli-public/releases/download/$Version/embed-syft-windows-amd64-$Version.exe"
try {
    Invoke-WebRequest -Uri $syftEmbedUrl -OutFile "C:\.local\bin\embed-syft-windows-amd64-$Version.exe"
    
    # Create copies with names the CLI expects
    Copy-Item "C:\.local\bin\embed-syft-windows-amd64-$Version.exe" "C:\.local\bin\embed-syft-amd64-$Version.exe"
    Copy-Item "C:\.local\bin\embed-syft-windows-amd64-$Version.exe" "C:\.local\bin\embed-syft-amd64-$Version"
    
    Write-Host "   ✅ Embedded Syft binary downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to download embedded Syft: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
# Step 4: Update PATH permanently
Write-Host "`n🔧 Updating system PATH..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
# Add C:\Tools\ssd-scanner if not already there
if ($currentPath -notlike "*C:\Tools\ssd-scanner*") {
    $newPath = $currentPath + ";C:\Tools\ssd-scanner"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
    Write-Host "   ✅ Added C:\Tools\ssd-scanner to PATH" -ForegroundColor Green
} else {
    Write-Host "   ℹ️ C:\Tools\ssd-scanner already in PATH" -ForegroundColor Blue
}
# Add C:\.local\bin if not already there
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
if ($currentPath -notlike "*C:\.local\bin*") {
    $newPath = $currentPath + ";C:\.local\bin"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
    Write-Host "   ✅ Added C:\.local\bin to PATH" -ForegroundColor Green
} else {
    Write-Host "   ℹ️ C:\.local\bin already in PATH" -ForegroundColor Blue
}
# Step 5: Update current session PATH
Write-Host "`n🔄 Refreshing current session PATH..." -ForegroundColor Yellow
$env:PATH += ";C:\Tools\ssd-scanner;C:\.local\bin"
# Step 6: Test installation
Write-Host "`n🧪 Testing installation..." -ForegroundColor Yellow
try {
    $cliVersion = & ssd-scanner-cli --help 2>&1 | Select-String "Starting the CLI"
    if ($cliVersion) {
        Write-Host "   ✅ SSD Scanner CLI working correctly" -ForegroundColor Green
    }
    
    # Test embedded syft exists
    if (Test-Path "C:\.local\bin\embed-syft-amd64-$Version.exe") {
        Write-Host "   ✅ Embedded Syft binary installed correctly" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ⚠️ Installation completed but testing failed: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   💡 Try opening a new PowerShell window" -ForegroundColor Blue
}
# Step 7: Show summary
Write-Host "`n🎉 Installation Summary:" -ForegroundColor Green
Write-Host "   📍 Main CLI: C:\Tools\ssd-scanner\ssd-scanner-cli.exe" -ForegroundColor White
Write-Host "   📍 Embedded Syft: C:\.local\bin\embed-syft-amd64-$Version.exe" -ForegroundColor White
Write-Host "   📍 Both directories added to system PATH" -ForegroundColor White
Write-Host "`n📝 Quick test command:" -ForegroundColor Cyan
Write-Host "   ssd-scanner-cli --help" -ForegroundColor Gray
Write-Host "`n💡 If commands don't work immediately, open a new PowerShell window" -ForegroundColor Blue
Write-Host "✅ Installation completed successfully!" -ForegroundColor Green
