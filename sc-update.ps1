# --- CONFIGURATION ---
$rsiRoot = "C:\Program Files\Roberts Space Industries\StarCitizen"
$livePath = "$rsiRoot\LIVE"
$ptuPath = "$rsiRoot\PTU"
$j2kPath = "C:\Users\Owner\Documents\JoyToKey"
$githubRepo = "ExoAE/ScCompLangPack"
$dropboxUrl = "https://www.dropbox.com/scl/fo/hd5fllfi6ftn57dkfp4f3/AOMWBjv79FhHD8xDFAMdBAI?rlkey=wwm1w6p39sytpffv2nr70b31j&dl=1"

# 1. PRE-FLIGHT QUESTIONS
Clear-Host
Write-Host "--- Star Citizen Update Automation ---`n" -ForegroundColor Magenta

$vNum       = Read-Host "Enter the target version number (e.g., 4.5)"
$doUpdate   = (Read-Host "Launch RSI Launcher to update LIVE? (y/n)") -eq 'y'
$doSwap     = (Read-Host "Rename PTU folder to LIVE to save download time? (y/n)") -eq 'y'
$doShaders  = (Read-Host "Clear Shader Cache? (y/n)") -eq 'y'
$doLang     = (Read-Host "Install Component Language Pack? (y/n)") -eq 'y'
$doBindings = (Read-Host "Install VKB Bindings & JoyToKey profiles? (y/n)") -eq 'y'

# 2. FOLDER SWAP
if ($doSwap) {
    if (Test-Path $ptuPath) {
        Write-Host "`n[SWAP] Renaming PTU to LIVE..." -ForegroundColor Yellow
        if (Test-Path $livePath) {
            $ts = Get-Date -Format "yyyyMMdd_HHmm"
            Rename-Item -Path $livePath -NewName "LIVE_Backup_$ts"
            Write-Host "Backup of old LIVE created."
        }
        Rename-Item -Path $ptuPath -NewName "LIVE"
    } else { Write-Warning "PTU folder not found, skipping swap." }
}

# 3. LAUNCHER UPDATE
if ($doUpdate) {
    Write-Host "`n[UPDATE] Opening RSI Launcher. Update LIVE, then return here." -ForegroundColor Cyan
    Start-Process "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe"
    Read-Host "Press Enter once the game update is 100% complete..."
}

# 4. SHADER CLEANUP
if ($doShaders) {
    $sFolder = "$env:LOCALAPPDATA\Star Citizen"
    if (Test-Path $sFolder) {
        Write-Host "`n[SHADERS] Clearing Shader Cache..." -ForegroundColor Yellow
        Remove-Item -Path "$sFolder\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 5. LANGUAGE PACK
if ($doLang) {
    Write-Host "`n[LANG] Fetching Language Pack from GitHub..." -ForegroundColor Cyan
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$githubRepo/releases/latest"
    $zipUrl = ($release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1).browser_download_url
    $tempZip = "$env:TEMP\Lang.zip"
    $tempEx  = "$env:TEMP\LangEx"
    
    Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip
    if (Test-Path $tempEx) { Remove-Item $tempEx -Recurse -Force }
    Expand-Archive -Path $tempZip -DestinationPath $tempEx -Force
    Copy-Item -Path "$tempEx\data" -Destination $livePath -Recurse -Force
    
    $cfg = "$livePath\user.cfg"
    $writeCfg = $true
    if (Test-Path $cfg) {
        if ((Read-Host "user.cfg exists. Overwrite with 'g_language = english'? (y/n)") -eq 'n') { $writeCfg = $false }
    }
    if ($writeCfg) { "g_language = english" | Out-File $cfg -Encoding ascii }
}

# 6. BINDINGS & JOYTOKEY
if ($doBindings) {
    Write-Host "`n[BINDINGS] Downloading VKB Bindings for version $vNum..." -ForegroundColor Cyan
    $bZip = "$env:TEMP\Bindings.zip"
    $bEx  = "$env:TEMP\BindEx"
    
    Invoke-WebRequest -Uri $dropboxUrl -OutFile $bZip
    if (Test-Path $bEx) { Remove-Item $bEx -Recurse -Force }
    Expand-Archive -Path $bZip -DestinationPath $bEx -Force
    
    $vFolder = Get-ChildItem -Path $bEx -Filter "*SC Alpha $vNum*" -Recurse -Directory | Select-Object -First 1
    
    if ($vFolder) {
        # XMLs to Star Citizen
        $scMap = "$livePath\USER\Client\0\Controls\Mappings"
        if (-not (Test-Path $scMap)) { New-Item $scMap -ItemType Directory -Force }
        Get-ChildItem $vFolder.FullName -Filter "*.xml" -Recurse | Copy-Item -Destination $scMap -Force
        
        # CFGs to JoyToKey
        if (-not (Test-Path $j2kPath)) { New-Item $j2kPath -ItemType Directory -Force }
        Get-ChildItem $vFolder.FullName -Filter "*.cfg" -Recurse | Copy-Item -Destination $j2kPath -Force
        
        Write-Host "Bindings and J2K profiles updated successfully." -ForegroundColor Green
    } else { Write-Error "Could not find folder for version $vNum in Dropbox zip." }
}

Write-Host "`n--- All selected tasks complete! ---" -ForegroundColor Magenta
