# --- SETTINGS ---
$rsiRoot = "C:\Program Files\Roberts Space Industries\StarCitizen"
$livePath = "$rsiRoot\LIVE"
$ptuPath = "$rsiRoot\PTU"
$j2kPath = "C:\Users\Owner\Documents\JoyToKey"
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
        }
        Rename-Item -Path $ptuPath -NewName "LIVE"
    } else {
        Write-Warning "PTU folder not found. Proceeding with standard update."
    }
}

# 3. LAUNCHER UPDATE
Write-Host "Starting RSI Launcher. Update LIVE then press Enter here..." -ForegroundColor Cyan
Start-Process "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe"
Read-Host "Press Enter once the game update is finished..."

# 4. SHADER CACHE CLEANUP
$shaderPath = "$env:LOCALAPPDATA\Star Citizen"
if (Test-Path $shaderPath) {
    if ((Read-Host "Clear Shader Cache? (Y/N)") -eq "y") {
        Remove-Item -Path "$shaderPath\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Shader Cache cleared." -ForegroundColor Green
    }
}

# 5. INSTALL LANGUAGE PACK
Write-Host "Installing Language Pack..." -ForegroundColor Cyan
$releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$githubRepo/releases/latest"
$assetUrl = ($releaseInfo.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1).browser_download_url
$langZip = "$env:TEMP\LangPack.zip"
$langExtract = "$env:TEMP\LangPackExtract"

Invoke-WebRequest -Uri $assetUrl -OutFile $langZip
if (Test-Path $langExtract) { Remove-Item $langExtract -Recurse -Force }
Expand-Archive -Path $langZip -DestinationPath $langExtract -Force

# user.cfg Logic
$cfgPath = "$livePath\user.cfg"
if (Test-Path $cfgPath) {
    if ((Read-Host "user.cfg exists. Overwrite? (Y/N)") -eq "y") {
        "g_language = english" | Out-File -FilePath $cfgPath -Encoding ascii
    }
} else {
    "g_language = english" | Out-File -FilePath $cfgPath -Encoding ascii
}
Copy-Item -Path "$langExtract\data" -Destination $livePath -Recurse -Force

# 6. VKB BINDINGS & JOYTOKEY FILES
Write-Host "Downloading VKB Bindings..." -ForegroundColor Cyan
$bindingsZip = "$env:TEMP\Bindings.zip"
$bindingsExtract = "$env:TEMP\BindingsExtract"

Invoke-WebRequest -Uri $dropboxUrl -OutFile $bindingsZip
if (Test-Path $bindingsExtract) { Remove-Item $bindingsExtract -Recurse -Force }
Expand-Archive -Path $bindingsZip -DestinationPath $bindingsExtract -Force

$targetFolder = Get-ChildItem -Path $bindingsExtract -Filter "*$versionSearchString*" -Recurse -Directory | Select-Object -First 1

if ($targetFolder) {
    # Path for SC Mappings
    $mappingDest = "$livePath\USER\Client\0\Controls\Mappings"
    if (-not (Test-Path $mappingDest)) { New-Item -Path $mappingDest -ItemType Directory -Force }

    # A. Copy XML files to Star Citizen
    Get-ChildItem -Path $targetFolder.FullName -Filter "*.xml" -Recurse | Copy-Item -Destination $mappingDest -Force
    Write-Host "XML Mappings installed to Star Citizen." -ForegroundColor Green

    # B. Copy .cfg files to JoyToKey
    if (-not (Test-Path $j2kPath)) { New-Item -Path $j2kPath -ItemType Directory -Force }
    Get-ChildItem -Path $targetFolder.FullName -Filter "*.cfg" -Recurse | Copy-Item -Destination $j2kPath -Force
    Write-Host "JoyToKey profiles installed to $j2kPath." -ForegroundColor Green
} else {
    Write-Error "Could not find folder for $versionSearchString."
}

Write-Host "`nSetup complete! Remember to select the profile in JoyToKey before launching." -ForegroundColor Magenta
