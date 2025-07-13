if (!(Get-Command chezmoi -errorAction SilentlyContinue))
{
  winget install --source winget --accept-package-agreements twpayne.chezmoi
}

if (!(Get-Command git -errorAction SilentlyContinue))
{
  winget install --source winget --accept-package-agreements Git.Git
}

if (!(Get-Command pwsh -errorAction SilentlyContinue))
{
  winget install --source winget --accept-package-agreements Microsoft.PowerShell
}

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

chezmoi init --apply locus313
Write-Host "If new commands are not found, please restart your PowerShell session."