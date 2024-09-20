if (!(Get-Command chezmoi -errorAction SilentlyContinue))
{
  winget install --source winget --accept-package-agreements twpayne.chezmoi
}

refreshenv | Out-Null
chezmoi init --apply locus313