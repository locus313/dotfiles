Write-Host "Installing dotfiles using chezmoi..." -ForegroundColor Green

# Check and install required tools
$requiredTools = @(
    @{Name = "chezmoi"; Package = "twpayne.chezmoi"}
    @{Name = "git"; Package = "Git.Git"}
    @{Name = "pwsh"; Package = "Microsoft.PowerShell"}
    @{Name = "wt"; Package = "Microsoft.WindowsTerminal"}
)

foreach ($tool in $requiredTools) {
    if (!(Get-Command $tool.Name -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $($tool.Name)..." -ForegroundColor Yellow
        try {
            winget install --source winget --accept-package-agreements $tool.Package
        }
        catch {
            Write-Error "Failed to install $($tool.Name): $($_.Exception.Message)"
            exit 1
        }
    } else {
        Write-Host "$($tool.Name) is already installed" -ForegroundColor Green
    }
}

# Refresh PATH environment variable
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