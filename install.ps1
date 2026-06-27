Write-Host "Installing dotfiles using chezmoi..." -ForegroundColor Green

# Trust PSGallery to suppress untrusted repository prompts
if (Get-Command Set-PSResourceRepository -ErrorAction SilentlyContinue) {
    Set-PSResourceRepository -Name "PSGallery" -Trusted
}
if (Get-PSRepository -Name "PSGallery" -ErrorAction SilentlyContinue) {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

# Check and install required tools
$requiredTools = @(
    @{Name = "chezmoi"; Package = "twpayne.chezmoi"}
    @{Name = "git"; Package = "Git.Git"}
    @{Name = "pwsh"; Package = "Microsoft.PowerShell"}
    @{Name = "wt"; Package = "Microsoft.WindowsTerminal"}
)

# Install CaskaydiaCove Nerd Font from GitHub releases (not available in winget)
$fontRegistryPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
$fontAlreadyInstalled = Get-ItemProperty $fontRegistryPath -ErrorAction SilentlyContinue |
    Get-Member -Name "CaskaydiaCove*" -ErrorAction SilentlyContinue

if (-not $fontAlreadyInstalled) {
    Write-Host "Installing CaskaydiaCove Nerd Font..." -ForegroundColor Yellow
    try {
        $fontZipPath = Join-Path $env:TEMP "CascadiaCode.zip"
        $fontExtractPath = Join-Path $env:TEMP "CascadiaCodeNerd"
        $fontDestDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"

        Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip" -OutFile $fontZipPath -UseBasicParsing
        Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath -Force
        New-Item -ItemType Directory -Force -Path $fontDestDir | Out-Null

        Get-ChildItem -Path $fontExtractPath -Filter "*.ttf" | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination (Join-Path $fontDestDir $_.Name) -Force
            New-ItemProperty -Path $fontRegistryPath `
                -Name "$($_.BaseName) (TrueType)" -Value (Join-Path $fontDestDir $_.Name) -Force | Out-Null
        }

        Remove-Item $fontZipPath, $fontExtractPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "CaskaydiaCove Nerd Font installed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to install CaskaydiaCove Nerd Font: $($_.Exception.Message)"
        Write-Host "You may need to install the font manually from: https://github.com/ryanoasis/nerd-fonts/releases/latest" -ForegroundColor Yellow
    }
} else {
    Write-Host "CaskaydiaCove Nerd Font is already installed" -ForegroundColor Green
}

foreach ($tool in $requiredTools) {
    if (!(Get-Command $tool.Name -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $($tool.Name)..." -ForegroundColor Yellow
        try {
            winget install --id $tool.Package --exact --source winget `
                --accept-package-agreements --accept-source-agreements --silent
            # Refresh PATH so subsequent iterations can detect newly installed tools
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
        }
        catch {
            Write-Error "Failed to install $($tool.Name): $($_.Exception.Message)"
            exit 1
        }
    } else {
        Write-Host "$($tool.Name) is already installed" -ForegroundColor Green
    }
}

# Final PATH refresh to pick up any tools installed during this session
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "Initializing dotfiles from locus313/dotfiles..." -ForegroundColor Green
try {
    chezmoi init --apply locus313
    Write-Host "Dotfiles installation completed successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Failed to initialize dotfiles: $($_.Exception.Message)"
    exit 1
}

Write-Host "If new commands are not found, please restart your PowerShell session." -ForegroundColor Yellow