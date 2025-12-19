# --- ADMIN CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator!"
    Pause
    Exit
}

# --- CONFIGURATION ---
$rsiRoot = "C:\Program Files\Roberts Space Industries\StarCitizen"
$livePath = "$rsiRoot\LIVE"
$ptuPath = "$rsiRoot\PTU"
$j2kPath = "C:\Users\Owner\Documents\JoyToKey"
$githubRepo = "ExoAE/ScCompLangPack"

# 1. PRE-FLIGHT QUESTIONS
Clear-Host
Write-Host "--- Star Citizen Update Automation ---`n" -ForegroundColor Magenta

$dbInput = Read-Host "Paste the Dropbox URL for the Alpha folder ROOT"

# Ensure the URL uses dl=1 for direct download
if ($dbInput) {
    $dropboxUrl = $dbInput -replace 'dl=0', 'dl=1'
} else {
    Write-Error "Dropbox URL is required to proceed."
    Read-Host "Press Enter to exit..."
    return
}

$doSwap     = (Read-Host "Rename PTU folder to LIVE? (y/n)") -eq 'y'
$doShaders  = (Read-Host "Clear Shader Cache? (y/n)") -eq 'y'
$doUpdate   = (Read-Host "Launch RSI Launcher to update LIVE? (y/n)") -eq 'y'
$doLang     = (Read-Host "Install Component Language Pack? (y/n)") -eq 'y'
$doBindings = (Read-Host "Install VKB Bindings? (y/n)") -eq 'y'

# 2. FOLDER SWAP (Before Update)
if ($doSwap) {
    if (Test-Path $ptuPath) {
        Write-Host "`n[SWAP] Renaming PTU to LIVE..." -ForegroundColor Yellow
        if (Test-Path $livePath) {
            $ts = Get-Date -Format "yyyyMMdd_HHmm"
            Rename-Item -Path $livePath -NewName "LIVE_Backup_$ts"
            Write-Host "Old LIVE backed up."
        }
        Rename-Item -Path $ptuPath -NewName "LIVE"
        Write-Host "PTU folder successfully renamed to LIVE." -ForegroundColor Green
    } else { Write-Warning "PTU folder not found; skipping rename." }
}

# 3. SHADER CLEANUP
if ($doShaders) {
    $sFolder = "$env:LOCALAPPDATA\Star Citizen"
    if (Test-Path $sFolder) {
        Write-Host "`n[SHADERS] Clearing Shader Cache..." -ForegroundColor Yellow
        Remove-Item -Path "$sFolder\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Shader cache cleared." -ForegroundColor Green
    }
}

# 4. LAUNCHER UPDATE
if ($doUpdate) {
    Write-Host "`n[UPDATE] Opening RSI Launcher. Update/Verify LIVE, then return here." -ForegroundColor Cyan
    Start-Process "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe"
    Read-Host "Press Enter once the game update is 100% complete..."
}

# 5. LANGUAGE PACK & SMART USER.CFG (After Update)
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
            Write-Host "Appended language to user.cfg." -ForegroundColor Green
        }
    } else { 
        $langLine | Out-File $cfgFile -Encoding ascii 
        Write-Host "Created new user.cfg." -ForegroundColor Green
    }
}

# 6. BINDINGS EXTRACTION (After Update)
if ($doBindings) {
    Write-Host "`n[BINDINGS] Downloading ZIP from Dropbox Alpha Root..." -ForegroundColor Cyan
    $bZip = "$env:TEMP\Bindings.zip"
    Invoke-WebRequest -Uri $dropboxUrl -OutFile $bZip

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($bZip)
    
    $foundFiles = 0
    foreach ($entry in $zip.Entries) {
        if ($entry.FullName -like "*Dual VKB Gladiator NXT*") {
            $targetPath = $null
            
            if ($entry.Name -like "*.xml") { 
                $targetPath = "$livePath\USER\Client\0\Controls\Mappings" 
            }
            elseif ($entry.Name -like "*.cfg") { 
                $targetPath = $j2kPath 
            }

            if ($targetPath -and -not [string]::IsNullOrEmpty($entry.Name)) {
                if (-not (Test-Path $targetPath)) { New-Item $targetPath -ItemType Directory -Force | Out-Null }
                $destination = Join-Path $targetPath $entry.Name
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destination, $true)
                $foundFiles++
            }
        }
    }
    $zip.Dispose()
    Remove-Item $bZip -Force
    Write-Host "Success! Extracted $foundFiles VKB/JoyToKey files." -ForegroundColor Green
}

Write-Host "`n--- Setup Complete! Fly safe, Citizen. ---" -ForegroundColor Magenta
Read-Host "Press Enter to exit..."
