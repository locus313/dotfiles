## Description

<!-- What does this PR do? Why is it needed? -->

## Changes

<!-- List the files changed and what was changed -->

- [ ] Template file(s) modified: `dot_*.tmpl`
- [ ] New package(s) added: `.chezmoidata/packages.yaml`
- [ ] New external tool: `.chezmoiexternal.toml`
- [ ] New install script: `.chezmoiscripts/{platform}/`
- [ ] PowerShell change: `Microsoft.PowerShell_profile.ps1.tmpl` or `Scripts/Powershell/`
- [ ] New secret integration (Bitwarden / 1Password)
- [ ] Other: <!-- describe -->

## Platforms Tested

<!-- Check all platforms you've tested this on -->

- [ ] Linux (specify distro: ______)
- [ ] macOS
- [ ] Windows
- [ ] WSL2
- [ ] Not applicable / untestable locally

## Mode Tested

- [ ] pmode
- [ ] oagmode
- [ ] ptxmode
- [ ] No mode required

## Checklist

- [ ] Template changes use whitespace-trimming markers (`{{-` / `-}}`)
- [ ] New secrets wrapped in mode check (`{{- if .pmode }}`, etc.)
- [ ] New packages added to `.chezmoidata/packages.yaml` (not hardcoded in scripts)
- [ ] Install scripts are idempotent (`command -v` / `dpkg -l` guards)
- [ ] No secrets or credentials committed directly
- [ ] `chezmoi diff` reviewed before applying
- [ ] PowerShell changes don't push profile load time over 700ms
