# --- SETTINGS ---
$rsiRoot = "C:\Program Files\Roberts Space Industries\StarCitizen"
$livePath = "$rsiRoot\LIVE"
$ptuPath = "$rsiRoot\PTU"
$githubRepo = "ExoAE/ScCompLangPack"
$dropboxUrl = "https://www.dropbox.com/scl/fo/hd5fllfi6ftn57dkfp4f3/AOMWBjv79FhHD8xDFAMdBAI?rlkey=wwm1w6p39sytpffv2nr70b31j&dl=1"

# 1. VERSION INPUT
$versionNumber = Read-Host "Enter the version number (e.g., 4.5)"
$versionSearchString = "SC Alpha $versionNumber"

# 2. PTU TO LIVE SWAP LOGIC
$usePTU = Read-Host "Is your PTU folder up to date and do you want to use it for LIVE? (Y/N)"
if ($usePTU -eq "Y" -or $usePTU -eq "y") {
    if (Test-Path $ptuPath) {
        Write-Host "Renaming PTU to LIVE to save download time..." -ForegroundColor Yellow
        if (Test-Path $livePath) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            Rename-Item -Path $livePath -NewName "LIVE_Backup_$timestamp"
            Write-Host "Existing LIVE folder backed up to LIVE_Backup_$timestamp"
        }
        Rename-Item -Path $ptuPath -NewName "LIVE"
    } else {
        Write-Warning "PTU folder not found. Proceeding with standard update."
    }
}

# 3. LAUNCHER UPDATE
Write-Host "Starting RSI Launcher. Please update the LIVE universe and close/minimize it when done." -ForegroundColor Cyan
Start-Process "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe"
Read-Host "Press Enter once the game update is finished..."

# 4. INSTALL LANGUAGE PACK & USER.CFG LOGIC
Write-Host "Fetching Language Pack..." -ForegroundColor Cyan
$releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$githubRepo/releases/latest"
$assetUrl = ($releaseInfo.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1).browser_download_url
$langZip = "$env:TEMP\LangPack.zip"
$langExtract = "$env:TEMP\LangPackExtract"

Invoke-WebRequest -Uri $assetUrl -OutFile $langZip
if (Test-Path $langExtract) { Remove-Item $langExtract -Recurse -Force }
Expand-Archive -Path $langZip -DestinationPath $langExtract -Force

# Handle user.cfg overwrite
$cfgPath = "$livePath\user.cfg"
$copyCfg = $true

if (Test-Path $cfgPath) {
    $choice = Read-Host "user.cfg already exists. Overwrite it? (Y/N)"
    if ($choice -ne "Y" -and $choice -ne "y") { $copyCfg = $false }
}

# Copy Data
Copy-Item -Path "$langExtract\data" -Destination $livePath -Recurse -Force

# Apply or Update user.cfg
if ($copyCfg) {
    "g_language = english" | Out-File -FilePath $cfgPath -Encoding ascii
    Write-Host "user.cfg updated." -ForegroundColor Green
} else {
    Write-Host "Skipping user.cfg overwrite." -ForegroundColor Yellow
}

# 5. VKB BINDINGS (VERSION SPECIFIC)
Write-Host "Downloading VKB Bindings for $versionSearchString..." -ForegroundColor Cyan
$bindingsZip = "$env:TEMP\Bindings.zip"
$bindingsExtract = "$env:TEMP\BindingsExtract"

Invoke-WebRequest -Uri $dropboxUrl -OutFile $bindingsZip
if (Test-Path $bindingsExtract) { Remove-Item $bindingsExtract -Recurse -Force }
Expand-Archive -Path $bindingsZip -DestinationPath $bindingsExtract -Force

# Search for the folder inside the zip that matches "SC Alpha X.X"
$targetFolder = Get-ChildItem -Path $bindingsExtract -Filter "*$versionSearchString*" -Recurse -Directory | Select-Object -First 1

if ($targetFolder) {
    $mappingDest = "$livePath\USER\Client\0\Controls\Mappings"
    if (-not (Test-Path $mappingDest)) { New-Item -Path $mappingDest -ItemType Directory -Force }
    
    # Specifically looking for VKB folder or files inside the version folder
    Copy-Item -Path "$($targetFolder.FullName)\*" -Destination $mappingDest -Recurse -Force
    Write-Host "Bindings for $versionSearchString installed successfully." -ForegroundColor Green
} else {
    Write-Error "Could not find a folder named '$versionSearchString' in the Dropbox download."
}

Write-Host "`nSetup complete! You can now launch Star Citizen." -ForegroundColor Magenta
