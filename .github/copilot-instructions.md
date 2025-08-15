# Copilot Instructions for Patrick Lewis Dotfiles

## Project Overview
This is a cross-platform dotfiles management system using [chezmoi](https://chezmoi.io) for configuration templating and deployment across Windows, Linux (including WSL), and macOS environments.

## Architecture & Core Concepts

### Multi-Platform Templating System
- **Template files**: Use `.tmpl` extension with Go template syntax
- **Platform detection**: `{{ .chezmoi.os }}` determines Windows/Linux/Darwin behavior
- **WSL detection**: `{{ $wsl }}` variable auto-detects WSL environment
- **Mode system**: Three operational modes (`pmode`, `oagmode`, `ptxmode`) control feature sets

### Key Template Patterns
```go
{{- if eq .chezmoi.os "windows" -}}
  # Windows-specific configuration
{{- end }}
{{- if .wsl }}
  # WSL-specific overrides
{{- end }}
```

### Configuration Data Flow
1. `.chezmoi.toml.tmpl` prompts for user data (email, name, modes)
2. Mode flags control which features/scripts are enabled
3. Templates consume this data via `{{ .email }}`, `{{ .pmode }}`, etc.

## Essential Developer Workflows

### Installation Commands
- **Linux/macOS**: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/locus313/dotfiles/main/install.sh)"`
- **Windows**: `iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/locus313/dotfiles/main/install.ps1"))`

### Development Commands
- `chezmoi edit ~/.gitconfig` - Edit template files
- `chezmoi apply` - Deploy configurations
- `chezmoi diff` - Preview changes
- `cz` function - Mode-aware chezmoi wrapper (see `Scripts/PowerShell/chezmoi.ps1.tmpl`)

## Project-Specific Conventions

### File Naming
- `dot_filename.tmpl` → `~/.filename` (hidden files)
- `private_dot_ssh/` → `~/.ssh/` (private files, not in git)
- Platform subdirectories in `Scripts/`, `.chezmoiscripts/`

### Mode System
- **pmode**: Personal mode with Bitwarden integration
- **oagmode**: Enterprise mode with custom CA bundle and Bitwarden
- **ptxmode**: Corporate mode with 1Password integration

### PowerShell Integration
- Module auto-installation pattern in `Microsoft.PowerShell_profile.ps1.tmpl`
- Script sourcing from `~/Scripts/PowerShell/` directory
- Git shortcuts (`gs`, `ga`, `gc`, `gp`) in `githelpers.ps1.tmpl`

### External Dependencies
- `.chezmoiexternal.toml` manages binary downloads (oh-my-posh, direnv, aws-vault)
- Refresh period of 168h (weekly) for external tools
- Platform-specific binary selection using `{{ .chezmoi.arch }}`

## Critical Integration Points

### Password Manager Integration
- Pre-hooks in `.chezmoi.toml.tmpl` install password managers based on mode
- Bitwarden (`bw`) for pmode/oagmode
- 1Password (`op`) for ptxmode
- `cz` wrapper handles authentication (`$env:BW_SESSION`)

### SSH Configuration
- Mode-dependent SSH agent setup (Bitwarden SSH agent for oagmode)
- Platform-specific SSH command paths in git config
- WSL uses Windows OpenSSH: `/mnt/c/WINDOWS/System32/OpenSSH/ssh.exe`

### Shell Customization
- oh-my-posh with night-owl theme across all platforms
- Conditional module loading (posh-git, Terminal-Icons, PsReadLine)
- Azure CLI tab completion setup for PowerShell

## When Working on This Codebase
- Always test template changes across multiple platforms using `chezmoi diff`
- New features should respect the mode system - add mode checks where appropriate
- External tool updates go in `.chezmoiexternal.toml` with proper platform conditionals
- PowerShell scripts need Windows OS guards: `{{- if eq .chezmoi.os "windows" -}}`
