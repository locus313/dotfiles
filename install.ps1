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

refreshenv | Out-Null
chezmoi init --apply locus313