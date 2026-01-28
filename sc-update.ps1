# --- ADMIN CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator!"
    Pause; Exit
}

# --- PERSISTENCE LOGIC ---
$configFile = Join-Path $env:LOCALAPPDATA "sc_update_config.json"
if (Test-Path $configFile) {
    $json = Get-Content $configFile | ConvertFrom-Json
    $vars = @{
        rsiRoot = $json.rsiRoot
        j2kPath = $json.j2kPath
    }
} else {
    $vars = @{
        rsiRoot = "C:\Program Files\Roberts Space Industries\StarCitizen"
        j2kPath = "$env:USERPROFILE\Documents\JoyToKey"
    }
}

function Save-Settings { 
    $newJson = [PSCustomObject]$vars
    $newJson | ConvertTo-Json | Out-File $configFile -Force -Encoding utf8
}

$scriptRunning = $true
while ($scriptRunning) {
    # Path Sanitization: Strips trailing LIVE/PTU
    $cleanRoot = $vars.rsiRoot.TrimEnd('\').TrimEnd('/')
    if ($cleanRoot -like "*\LIVE") { $cleanRoot = $cleanRoot.Substring(0, $cleanRoot.Length - 5) }
    if ($cleanRoot -like "*\PTU")  { $cleanRoot = $cleanRoot.Substring(0, $cleanRoot.Length - 4) }
    
    $livePath = Join-Path $cleanRoot "LIVE"
    $ptuPath  = Join-Path $cleanRoot "PTU"
    
    # UI Validations
    $scValid = if (Test-Path -LiteralPath $livePath) { " (Valid)" } else { " (NOT FOUND!)" }
    $ptuValid = if (Test-Path -LiteralPath $ptuPath) { " (Found)" } else { " (Missing)" }
    $j2kValid = if (Test-Path -LiteralPath $vars.j2kPath) { " (Valid)" } else { " (NOT FOUND!)" }

    $menuItems = @(
        @{ Type = "Task";   Name = "Rename PTU folder to LIVE"; Selected = $false }
        @{ Type = "Task";   Name = "Clear Shader Cache"; Selected = $false }
        @{ Type = "Task";   Name = "Update via RSI Launcher"; Selected = $false }
        @{ Type = "Task";   Name = "Install Component Language Pack"; Selected = $false }
        @{ Type = "Task";   Name = "Install VKB Bindings & J2K Profiles"; Selected = $false }
        @{ Type = "Sep";    Name = "--- SETTINGS (Enter to Change) ---" }
        @{ Type = "Var";    Name = "SC Root$scValid"; Key = "rsiRoot"; Prompt = "Enter Root folder (contains LIVE and PTU folders)" }
        @{ Type = "Var";    Name = "J2K Path$j2kValid"; Key = "j2kPath"; Prompt = "Enter the JoyToKey folder path" }
        @{ Type = "Sep";    Name = "--- UTILITIES ---" }
        @{ Type = "Action"; Name = "Open LIVE Folder"; ID = "OPEN_SC" }
        @{ Type = "Action"; Name = "Open PTU Folder ($ptuValid)"; ID = "OPEN_PTU" }
        @{ Type = "Action"; Name = "Open JoyToKey Folder"; ID = "OPEN_J2K" }
        @{ Type = "Action"; Name = "START EXECUTION"; ID = "RUN" }
        @{ Type = "Action"; Name = "EXIT SCRIPT"; ID = "EXIT" }
    )

    $currentLine = 0
    $readyToExecute = $false

    while (-not $readyToExecute) {
        Clear-Host
        Write-Host "--- STAR CITIZEN UPDATE MANAGER ---" -ForegroundColor Magenta
        Write-Host "Arrows: Nav | Space: Toggle | [A] All | [C] Clear | Enter: Action`n" -ForegroundColor Gray

        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            $item = $menuItems[$i]; $pointer = if ($i -eq $currentLine) { "> " } else { "  " }
            $text = switch ($item.Type) {
                "Task" { "$pointer $(if($item.Selected){'[X]'}else{'[ ]'}) $($item.Name)" }
                "Var"  { "$pointer $($item.Name): $($vars[$item.Key])" }
                "Sep"  { "   $($item.Name)" }
                "Action" { "$pointer [[ $($item.Name) ]]" }
            }
            $color = "White"; if ($i -eq $currentLine) { $color = "Cyan" } 
            elseif ($item.Type -eq "Sep") { $color = "DarkGray" }
            elseif ($item.Name -like "*NOT FOUND*" -or $item.Name -like "*Missing*") { $color = "Red" }
            Write-Host $text -ForegroundColor $color
        }

        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow"   { do { $currentLine = if ($currentLine -gt 0) { $currentLine - 1 } else { $menuItems.Count - 1 } } while ($menuItems[$currentLine].Type -eq "Sep") }
            "DownArrow" { do { $currentLine = if ($currentLine -lt $menuItems.Count - 1) { $currentLine + 1 } else { 0 } } while ($menuItems[$currentLine].Type -eq "Sep") }
            "Spacebar"  { if ($menuItems[$currentLine].Type -eq "Task") { $menuItems[$currentLine].Selected = -not $menuItems[$currentLine].Selected } }
            "A"         { foreach ($m in $menuItems) { if ($m.Type -eq "Task") { $m.Selected = $true } } }
            "C"         { foreach ($m in $menuItems) { if ($m.Type -eq "Task") { $m.Selected = $false } } }
            "Enter"     { 
                if ($menuItems[$currentLine].Type -eq "Var") {
                    $keyToSet = $menuItems[$currentLine].Key
                    Write-Host "`n$($menuItems[$currentLine].Prompt):" -ForegroundColor Yellow
                    $newVal = (Read-Host).Trim().Trim('"').Trim("'")
                    if (Test-Path -LiteralPath $newVal) { 
                        $vars[$keyToSet] = $newVal; Save-Settings
                        Write-Host "Saved!" -ForegroundColor Green; Start-Sleep -s 1
                        $readyToExecute = $false; break 
                    } else { Write-Host "Path Invalid!" -ForegroundColor Red; Start-Sleep -s 1 }
                }
                elseif ($menuItems[$currentLine].ID -eq "OPEN_SC") { if(Test-Path -LiteralPath $livePath){ Start-Process $livePath } }
                elseif ($menuItems[$currentLine].ID -eq "OPEN_PTU") { if(Test-Path -LiteralPath $ptuPath){ Start-Process $ptuPath } }
                elseif ($menuItems[$currentLine].ID -eq "OPEN_J2K") { if(Test-Path -LiteralPath $vars.j2kPath){ Start-Process $vars.j2kPath } }
                elseif ($menuItems[$currentLine].ID -eq "EXIT") { $scriptRunning = $false; $readyToExecute = $true }
                elseif ($menuItems[$currentLine].ID -eq "RUN") { 
                    if (-not (Test-Path -LiteralPath $livePath)) {
                        Write-Host "`nError: Cannot find LIVE folder." -ForegroundColor Red; Start-Sleep -s 2
                    } else { $readyToExecute = $true }
                }
                elseif ($menuItems[$currentLine].Type -eq "Task") { $menuItems[$currentLine].Selected = -not $menuItems[$currentLine].Selected }
            }
        }
    }

    if (-not $scriptRunning) { break }

    # --- EXECUTION ---
    Clear-Host
    if ($menuItems[4].Selected) {
        $dbInput = Read-Host "Paste the Dropbox Alpha folder ROOT URL"
        $dropboxUrl = $dbInput -replace 'dl=0', 'dl=1'
    }

    # 1. PTU Swap
    if ($menuItems[0].Selected) {
        Write-Host "`n[1/5] Swapping PTU to LIVE..." -ForegroundColor Yellow
        if (Test-Path -LiteralPath $ptuPath) {
            if (Test-Path -LiteralPath $livePath) { 
                Rename-Item -LiteralPath $livePath -NewName "LIVE_Backup_$(Get-Date -f yyyyMMdd_HHmm)" 
            }
            Rename-Item -LiteralPath $ptuPath -NewName "LIVE"
            Write-Host "Success." -ForegroundColor Green
        }
    }

    # 2. Shaders
    if ($menuItems[1].Selected) {
        Write-Host "[2/5] Clearing Shaders..." -ForegroundColor Yellow
        $sFolder = "$env:LOCALAPPDATA\Star Citizen"
        if (Test-Path -LiteralPath $sFolder) { Remove-Item "$sFolder\*" -Recurse -Force -ErrorAction SilentlyContinue }
    }

    # 3. Launcher
    if ($menuItems[2].Selected) {
        Write-Host "[3/5] Launching RSI Launcher..." -ForegroundColor Cyan
        $launcher = Join-Path $cleanRoot "..\RSI Launcher\RSI Launcher.exe"
        if (Test-Path -LiteralPath $launcher) { Start-Process $launcher }
        Read-Host "Press Enter once update is 100% complete..."
    }

    # 4. Lang Pack
    if ($menuItems[3].Selected) {
        Write-Host "[4/5] Installing Lang Pack..." -ForegroundColor Cyan
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/ExoAE/ScCompLangPack/releases/latest"
        $zipUrl = ($release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1).browser_download_url
        $tempZip = "$env:TEMP\Lang.zip"; Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip
        Expand-Archive $tempZip -DestinationPath "$env:TEMP\LangEx" -Force
        Copy-Item "$env:TEMP\LangEx\data" -Destination $livePath -Recurse -Force
        $cfg = Join-Path $livePath "user.cfg"
        if (Test-Path -LiteralPath $cfg) { 
            if ((Get-Content -LiteralPath $cfg) -notcontains "g_language = english") { Add-Content -Path $cfg -Value "`ng_language = english" } 
        } else { "g_language = english" | Out-File $cfg -Encoding ascii }
    }

    # 5. Bindings
    if ($menuItems[4].Selected) {
        Write-Host "[5/5] Extracting VKB Bindings..." -ForegroundColor Cyan
        $bZip = "$env:TEMP\Bindings.zip"; Invoke-WebRequest -Uri $dropboxUrl -OutFile $bZip
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($bZip)
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -like "*Dual VKB Gladiator NXT*") {
                $dest = if ($entry.Name -like "*.xml") { Join-Path $livePath "USER\Client\0\Controls\Mappings" }
                        elseif ($entry.Name -like "*.cfg") { $vars["j2kPath"] }
                if ($dest -and $entry.Name) {
                    if (-not (Test-Path -LiteralPath $dest)) { New-Item $dest -ItemType Directory -Force | Out-Null }
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $dest $entry.Name), $true)
                }
            }
        }
        $zip.Dispose(); Remove-Item $bZip -Force
    }

    Write-Host "`nTasks finished. Press any key to return to menu..." -ForegroundColor Magenta
    [Console]::ReadKey($true) | Out-Null
}
