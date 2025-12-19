# --- CONFIGURATION ---
$rsiRoot = "D:\Star Citizen PTU\StarCitizen\"
$livePath = "$rsiRoot\LIVE"
$ptuPath = "$rsiRoot\PTU"
$j2kPath = "C:\Users\andyp\OneDrive\Documents\JoyToKey"
$githubRepo = "ExoAE/ScCompLangPack"

# 1. PRE-FLIGHT QUESTIONS
Clear-Host
Write-Host "--- Star Citizen Update Automation ---`n" -ForegroundColor Magenta

$vNum       = Read-Host "Enter the version number (e.g., 4.5)"
$dbInput    = Read-Host "Paste the Dropbox URL for the $vNum folder (or press Enter for default)"

# Ensure the URL uses dl=1 for direct download
if ($dbInput) {
    $dropboxUrl = $dbInput -replace 'dl=0', 'dl=1'
} else {
    # Default fallback URL (currently 4.4 folder)
    $dropboxUrl = "https://www.dropbox.com/scl/fo/hd5fllfi6ftn57dkfp4f3/AExJR6pW0EA8WUxZqc-ACK8/SC%20Alpha%204.4?dl=1&rlkey=wwm1w6p39sytpffv2nr70b31j"
}

$doUpdate   = (Read-Host "Launch RSI Launcher to update LIVE? (y/n)") -eq 'y'
$doSwap     = (Read-Host "Rename PTU folder to LIVE? (y/n)") -eq 'y'
$doShaders  = (Read-Host "Clear Shader Cache? (y/n)") -eq 'y'
$doLang     = (Read-Host "Install Component Language Pack? (y/n)") -eq 'y'
$doBindings = (Read-Host "Install VKB Bindings? (y/n)") -eq 'y'

# 2. FOLDER SWAP
if ($doSwap) {
    if (Test-Path $ptuPath) {
        Write-Host "`n[SWAP] Renaming PTU to LIVE..." -ForegroundColor Yellow
        if (Test-Path $livePath) {
            $ts = Get-Date -Format "yyyyMMdd_HHmm"
            Rename-Item -Path $livePath -NewName "LIVE_Backup_$ts"
        }
        Rename-Item -Path $ptuPath -NewName "LIVE"
    } else { Write-Warning "PTU folder not found." }
}

# 3. LAUNCHER UPDATE
if ($doUpdate) {
    Write-Host "`n[UPDATE] Opening RSI Launcher..." -ForegroundColor Cyan
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

# 5. LANGUAGE PACK & SMART USER.CFG APPEND
if ($doLang) {
    Write-Host "`n[LANG] Downloading Language Pack..." -ForegroundColor Cyan
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$githubRepo/releases/latest"
    $zipUrl = ($release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1).browser_download_url
    $tempZip = "$env:TEMP\Lang.zip"
    $tempEx  = "$env:TEMP\LangEx"
    
    Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip
    if (Test-Path $tempEx) { Remove-Item $tempEx -Recurse -Force }
    Expand-Archive -Path $tempZip -DestinationPath $tempEx -Force
    Copy-Item -Path "$tempEx\data" -Destination $livePath -Recurse -Force
    
    $cfgFile = "$livePath\user.cfg"
    $langLine = "g_language = english"
    if (Test-Path $cfgFile) {
        $existing = Get-Content $cfgFile
        if ($existing -notcontains $langLine) {
            Add-Content -Path $cfgFile -Value "`n$langLine"
            Write-Host "Appended language setting to user.cfg." -ForegroundColor Green
        }
    } else { 
        $langLine | Out-File $cfgFile -Encoding ascii 
        Write-Host "Created new user.cfg." -ForegroundColor Green
    }
}

# 6. BINDINGS (TARGETED DOWNLOAD & EXTRACTION)
if ($doBindings) {
    Write-Host "`n[BINDINGS] Downloading targeted folder..." -ForegroundColor Cyan
    $bZip = "$env:TEMP\Bindings.zip"
    Invoke-WebRequest -Uri $dropboxUrl -OutFile $bZip

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($bZip)
    
    $foundFiles = 0
    foreach ($entry in $zip.Entries) {
        # Selective extraction of the Dual VKB folder
        if ($entry.FullName -like "*Dual VKB Gladiator NXT*") {
            $targetPath = ""
            if ($entry.Name -like "*.xml") { $targetPath = "$livePath\USER\Client\0\Controls\Mappings" }
            elseif ($entry.Name -like "*.cfg") { $targetPath = $j2kPath }

            if ($targetPath) {
                if (-not (Test-Path $targetPath)) { New-Item $targetPath -ItemType Directory -Force | Out-Null }
                $destination = Join-Path $targetPath $entry.Name
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destination, $true)
                $foundFiles++
            }
        }
    }
    $zip.Dispose()
    Remove-Item $bZip -Force
    Write-Host "VKB and JoyToKey files updated." -ForegroundColor Green
}

Write-Host "`n--- Setup Complete! ---" -ForegroundColor Magenta
Read-Host "Press Enter to exit..."
