# AGENTS.md — Cross-Platform Dotfiles (locus313/dotfiles)

## Project Overview

Personal dotfiles managed with [chezmoi](https://chezmoi.io) for cross-platform deployment across **Windows**, **Linux** (including WSL2), and **macOS**. Configuration is templated using Go template syntax — files named `*.tmpl` expand at `chezmoi apply` time based on OS, distro, and operational mode.

Do **not** hardcode usernames, hostnames, or secrets. All sensitive values come from Bitwarden (pmode/oagmode) or 1Password (ptxmode) via chezmoi template functions.

## Repository Structure

```
.
├── .chezmoi.toml.tmpl          # Bootstrap config — prompts for mode/user on first run
├── .chezmoidata/
│   └── packages.yaml           # Package lists consumed by install scripts
├── .chezmoiexternal.toml       # External binary/archive downloads (chezmoi externals)
├── .chezmoihooks/              # Pre-read-source-state hooks (install password managers)
├── .chezmoiscripts/
│   ├── linux/                  # Linux-specific install scripts (.sh.tmpl)
│   ├── macos/                  # macOS-specific install scripts (.sh.tmpl)
│   └── windows/                # Windows-specific install scripts (.ps1.tmpl)
├── dot_bashrc.tmpl             # → ~/.bashrc
├── dot_bash_aliases.tmpl       # → ~/.bash_aliases
├── dot_zshrc.tmpl              # → ~/.zshrc
├── dot_zprofile.tmpl           # → ~/.zprofile
├── dot_profile.tmpl            # → ~/.profile
├── dot_gitconfig.tmpl          # → ~/.gitconfig
├── dot_config/powershell/      # → ~/.config/powershell/
├── dot_local/share/            # → ~/.local/share/ (themes, tools)
├── dot_terraform-version.tmpl  # → ~/.terraform-version (tfenv pin)
├── Microsoft.PowerShell_profile.ps1.tmpl  # → PowerShell $PROFILE
├── Scripts/Powershell/         # PowerShell helper modules
├── Documents/PowerShell/       # PowerShell profile extras
├── AppData/Roaming/            # Windows AppData templates
├── private_dot_ssh/            # → ~/.ssh/ (private, not committed)
├── spec/                       # Architecture specification documents
├── install.sh                  # Bootstrap installer (Linux/macOS)
└── install.ps1                 # Bootstrap installer (Windows)
```

## Tech Stack

| Component | Detail |
|-----------|--------|
| Template engine | chezmoi Go templates (`{{ }}` syntax) |
| Shell | Bash (Linux), Zsh (macOS), PowerShell 7 (Windows/cross-platform) |
| Package managers | `apt` (Debian/Ubuntu/Pop), `dnf` (Fedora/AlmaLinux), `brew` (macOS), `winget` (Windows) |
| Password managers | Bitwarden (`bw`) for pmode/oagmode; 1Password (`op`) for ptxmode |
| Prompt | oh-my-posh with `night-owl` theme |
| Shell tools | `eza`, `bat`, `zoxide`, `direnv`, `fzf` |
| External binaries | Managed via `.chezmoiexternal.toml` (auto-downloaded, weekly refresh) |

## Operational Modes

The mode system controls which features and secrets are activated. Set during `chezmoi init`.

| Mode | Variable | Description |
|------|----------|-------------|
| pmode | `.pmode` | Personal — Bitwarden secrets |
| oagmode | `.oagmode` | Enterprise — Bitwarden + custom CA bundle |
| ptxmode | `.ptxmode` | Corporate — 1Password secrets |

Always check mode in templates: `{{- if (or .pmode .oagmode) }}` for Bitwarden-based modes.

## Build & Run

```bash
# Apply all dotfiles to the current system
chezmoi apply

# Preview changes without applying
chezmoi diff

# Edit a managed file
chezmoi edit ~/.bashrc

# Re-run install scripts
chezmoi apply --force
```

## Testing Changes

```bash
# Validate template rendering without applying
chezmoi cat ~/.bashrc

# Dry-run to see what would change
chezmoi diff

# Check template data values
chezmoi data
```

## Key Patterns and Conventions

### File naming
- `dot_filename.tmpl` → `~/.filename`
- `private_dot_ssh/` → `~/.ssh/` (private, 600 permissions)
- Platform scripts in `.chezmoiscripts/{platform}/`

### Template OS guards
```go
{{- if eq .chezmoi.os "linux" -}}        # Linux only
{{- if eq .chezmoi.os "windows" -}}      # Windows only
{{- if (or (eq .chezmoi.os "windows") (eq .chezmoi.os "darwin")) -}}  # Win+Mac
{{- if .wsl }}                           # WSL only
{{- if (eq .chezmoi.osRelease.id "debian" "ubuntu" "pop") }}  # Debian family
```

### Secrets
```go
{{ (bitwardenFields "item" "chezmoi").fieldname.value | quote }}  # Bitwarden
{{ (onepasswordItemFields "chezmoi").fieldname.value | quote }}   # 1Password
```
Always pipe secrets through `| quote` to handle special characters.

### Script ordering
Scripts in `.chezmoiscripts/` use numeric prefixes: `run_onchange_01-`, `run_onchange_02-`, etc.

## Adding a New Feature

1. **New shell alias or function** → `dot_bash_aliases.tmpl` or `dot_zshrc.tmpl`; add platform guard if needed
2. **New package** → `.chezmoidata/packages.yaml` under `packages.{os}.{manager}` (and `packages.{os}.{mode}.{manager}` if mode-specific)
3. **New VS Code extension** → `.chezmoidata/packages.yaml` under `extensions.{os}.vscode`
4. **New external binary** → `.chezmoiexternal.toml` with `type = "file"` or `type = "archive-file"`, `refreshPeriod = "168h"`, and `{{ .chezmoi.os }}`/`{{ .chezmoi.arch }}` in the URL
5. **New secret** → add to Bitwarden/1Password item `chezmoi`, then access via `bitwardenFields`/`onepasswordItemFields`; wrap in mode check
6. **New install script** → `.chezmoiscripts/{platform}/run_onchange_NN-name.{sh|ps1}.tmpl`; use `run_once_` prefix for one-time scripts

## Common Pitfalls

- **Whitespace in templates** — always use `{{-` / `-}}` trimming markers to avoid blank lines in output
- **Missing mode check** — new secrets must be guarded by mode (`{{- if .pmode }}`, etc.)
- **Hardcoded versions** — never hardcode tool versions in templates; pin in `.chezmoiexternal.toml` or `.terraform-version`
- **Script idempotency** — always check `if ! command -v tool >/dev/null 2>&1` before installing
- **PowerShell load time** — profile changes must not push load time over 700ms; use lazy loading patterns
- **WSL paths** — WSL uses Windows OpenSSH at `/mnt/c/WINDOWS/System32/OpenSSH/ssh.exe`; do not substitute Linux ssh
