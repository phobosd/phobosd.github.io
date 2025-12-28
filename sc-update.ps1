# --- ADMIN CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator!"
    Pause; Exit
}

# --- PERSISTENCE LOGIC ---
$configFile = Join-Path $PSScriptRoot "sc_update_config.json"
if (Test-Path $configFile) {
    $vars = ConvertFrom-Json (Get-Content $configFile)
} else {
    $vars = [PSCustomObject]@{
        rsiRoot = "C:\Program Files\Roberts Space Industries\StarCitizen"
        j2kPath = "C:\Users\Owner\Documents\JoyToKey"
    }
}

function Save-Settings {
    $vars | ConvertTo-Json | Out-File $configFile
}

# --- GLOBAL LOOP ---
$scriptRunning = $true
while ($scriptRunning) {

    # --- MENU DATA ---
    # We rebuild this each loop to reset the "Selected" state if desired, 
    # or keep it outside the loop if you want selections to persist.
    $menuItems = @(
        @{ Type = "Task";   Name = "Rename PTU folder to LIVE"; Selected = $false }
        @{ Type = "Task";   Name = "Clear Shader Cache"; Selected = $false }
        @{ Type = "Task";   Name = "Update via RSI Launcher"; Selected = $false }
        @{ Type = "Task";   Name = "Install Component Language Pack"; Selected = $false }
        @{ Type = "Task";   Name = "Install VKB Bindings & J2K Profiles"; Selected = $false }
        @{ Type = "Sep";    Name = "--- SETTINGS (Enter to Change) ---" }
        @{ Type = "Var";    Name = "SC Root"; Key = "rsiRoot" }
        @{ Type = "Var";    Name = "J2K Path"; Key = "j2kPath" }
        @{ Type = "Action"; Name = "START EXECUTION"; ID = "RUN" }
        @{ Type = "Action"; Name = "EXIT SCRIPT"; ID = "EXIT" }
    )

    $currentLine = 0
    $readyToExecute = $false

    # --- INPUT LOOP ---
    while (-not $readyToExecute) {
        Clear-Host
        Write-Host "--- STAR CITIZEN UPDATE MANAGER ---" -ForegroundColor Magenta
        Write-Host "Arrows: Nav | Space: Toggle | [A] All | [C] Clear | Enter: Edit/Start`n" -ForegroundColor Gray

        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            $item = $menuItems[$i]
            $pointer = if ($i -eq $currentLine) { "> " } else { "  " }
            
            if ($item.Type -eq "Task") {
                $check = if ($item.Selected) { "[X]" } else { "[ ]" }
                $text = "$pointer $check $($item.Name)"
            }
            elseif ($item.Type -eq "Var") {
                $text = "$pointer $($item.Name): $($vars.$($item.Key))"
            }
            elseif ($item.Type -eq "Sep") {
                $text = "   $($item.Name)"
            }
            else {
                $text = "$pointer [[ $($item.Name) ]]"
            }

            $color = "White"
            if ($i -eq $currentLine) { $color = "Cyan" } 
            elseif ($item.Type -eq "Sep") { $color = "DarkGray" }

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
                    $newPath = Read-Host "`nEnter new path for $($menuItems[$currentLine].Name)"
                    if (Test-Path $newPath) { $vars.$($menuItems[$currentLine].Key) = $newPath; Save-Settings } 
                    else { Write-Host "Invalid Path!" -ForegroundColor Red; Start-Sleep -s 1 }
                }
                elseif ($menuItems[$currentLine].ID -eq "EXIT") { $scriptRunning = $false; $readyToExecute = $true }
                elseif ($menuItems[$currentLine].ID -eq "RUN") { $readyToExecute = $true }
                elseif ($menuItems[$currentLine].Type -eq "Task") { $menuItems[$currentLine].Selected = -not $menuItems[$currentLine].Selected }
            }
        }
    }

    if (-not $scriptRunning) { break }

    # --- EXECUTION ---
    Clear-Host
    $livePath = "$($vars.rsiRoot)\LIVE"
    $ptuPath  = "$($vars.rsiRoot)\PTU"
    
    if ($menuItems[4].Selected) {
        $dbInput = Read-Host "Paste the Dropbox URL for the Alpha folder ROOT"
        $dropboxUrl = $dbInput -replace 'dl=0', 'dl=1'
    }

    if ($menuItems[0].Selected) {
        Write-Host "`n[1/5] Swapping PTU..." -ForegroundColor Yellow
        if (Test-Path $ptuPath) {
            if (Test-Path $livePath) { Rename-Item $livePath -NewName "LIVE_Backup_$(Get-Date -f yyyyMMdd_HHmm)" }
            Rename-Item $ptuPath -NewName "LIVE"
        }
    }

    if ($menuItems[1].Selected) {
        Write-Host "[2/5] Clearing Shaders..." -ForegroundColor Yellow
        $sFolder = "$env:LOCALAPPDATA\Star Citizen"
        if (Test-Path $sFolder) { Remove-Item "$sFolder\*" -Recurse -Force -ErrorAction SilentlyContinue }
    }

    if ($menuItems[2].Selected) {
        Write-Host "[3/5] Launching Update..." -ForegroundColor Cyan
        $launcher = "$($vars.rsiRoot)\..\RSI Launcher\RSI Launcher.exe"
        if (Test-Path $launcher) { Start-Process $launcher }
        Read-Host "Press Enter once update is complete..."
    }

    if ($menuItems[3].Selected) {
        Write-Host "[4/5] Installing Lang Pack..." -ForegroundColor Cyan
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/ExoAE/ScCompLangPack/releases/latest"
        $zipUrl = ($release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1).browser_download_url
        $tempZip = "$env:TEMP\Lang.zip"; Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip
        Expand-Archive $tempZip -DestinationPath "$env:TEMP\LangEx" -Force
        Copy-Item "$env:TEMP\LangEx\data" -Destination $livePath -Recurse -Force
        $cfg = "$livePath\user.cfg"
        if (Test-Path $cfg) { if ((Get-Content $cfg) -notcontains "g_language = english") { Add-Content $cfg -Value "`ng_language = english" } }
        else { "g_language = english" | Out-File $cfg -Encoding ascii }
    }

    if ($menuItems[4].Selected) {
        Write-Host "[5/5] Installing Bindings..." -ForegroundColor Cyan
        $bZip = "$env:TEMP\Bindings.zip"; Invoke-WebRequest -Uri $dropboxUrl -OutFile $bZip
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($bZip)
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -like "*Dual VKB Gladiator NXT*") {
                $dest = if ($entry.Name -like "*.xml") { "$livePath\USER\Client\0\Controls\Mappings" }
                        elseif ($entry.Name -like "*.cfg") { $vars.j2kPath }
                if ($dest -and $entry.Name) {
                    if (-not (Test-Path $dest)) { New-Item $dest -ItemType Directory -Force | Out-Null }
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $dest $entry.Name), $true)
                }
            }
        }
        $zip.Dispose(); Remove-Item $bZip -Force
    }

    Write-Host "`nTasks complete! Press any key to return to the menu..." -ForegroundColor Magenta
    [Console]::ReadKey($true) | Out-Null
}
