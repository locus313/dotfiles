# Copilot Instructions for Patrick Lewis Dotfiles

## Project Overview
This is a cross-platform dotfiles management system using [chezmoi](https://chezmoi.io) for configuration templating and deployment across Windows, Linux (including WSL), and macOS environments.

## Architecture & Core Concepts

### Multi-Platform Templating System
- **Template files**: Use `.tmpl` extension with Go template syntax
- **Platform detection**: `{{ .chezmoi.os }}` determines `windows`, `linux`, or `darwin`
- **WSL detection**: `{{ .wsl }}` variable (bool) auto-detects WSL environment
- **OS release detection**: `{{ .chezmoi.osRelease.id }}` for distro-specific logic (e.g., `debian`, `ubuntu`, `pop`, `fedora`, `almalinux`)
- **Architecture detection**: `{{ .chezmoi.arch }}` returns `amd64`, `arm64`, or `386`
- **Mode system**: Three operational modes (`pmode`, `oagmode`, `ptxmode`) control feature sets

### Key Template Patterns

Always use whitespace-trimming markers (`{{-` / `-}}`) for clean output:

```go
{{- if eq .chezmoi.os "windows" -}}
  # Windows-specific configuration
{{- end }}

{{- if .wsl }}
  # WSL-specific overrides
{{- end }}

{{- if (or (eq .chezmoi.os "windows") (eq .chezmoi.os "darwin")) -}}
  # Windows or macOS
{{- end }}

{{- if (eq .chezmoi.osRelease.id "debian" "ubuntu" "pop") }}
  # Debian-family distros
{{- end }}

{{- if (and (eq .chezmoi.os "linux") (eq .chezmoi.osRelease.id "pop")) }}
  # Pop!_OS specific
{{- end }}

{{- if (or .pmode .oagmode) }}
  # Bitwarden-based modes
{{- end }}
```

### Go Template Data Access Patterns
- User data: `{{ .email }}`, `{{ .name }}`
- Mode flags: `{{ .pmode }}`, `{{ .oagmode }}`, `{{ .ptxmode }}`, `{{ .wsl }}`
- Chezmoi metadata: `{{ .chezmoi.os }}`, `{{ .chezmoi.arch }}`, `{{ .chezmoi.osRelease.id }}`
- Package lists: `{{ range .packages.linux.apts }}`, `{{ range .packages.windows.winget }}`
- Bitwarden secrets: `{{ (bitwardenFields "item" "chezmoi").fieldname.value | quote }}`
- 1Password secrets: `{{ (onepasswordItemFields "chezmoi").fieldname.value | quote }}`
- String quoting: Always pipe secrets through `| quote` to handle special characters

### Configuration Data Flow
1. `.chezmoi.toml.tmpl` prompts for user data (email, name, modes) using `promptStringOnce` / `promptBoolOnce`
2. Mode flags control which features/scripts are enabled
3. Templates consume this data via `{{ .email }}`, `{{ .pmode }}`, etc.
4. `.chezmoidata/packages.yaml` provides package lists consumed by install scripts
5. Pre-hooks automatically install password managers before source state reads

### Chezmoi Scripts and Hooks Structure
- `.chezmoiscripts/{platform}/` - Platform-specific installation scripts
- `.chezmoihooks/` - Lifecycle hooks (pre-read-source-state for password managers)
- `run_onchange_` prefix ensures scripts only run when templates/data change
- `run_once_` prefix for one-time setup scripts
- Scripts use numbered prefixes for ordering (e.g., `run_onchange_01-`, `run_onchange_02-`)

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
- PowerShell scripts use `PascalCase` naming under `Scripts/Powershell/`

### Mode System
- **pmode**: Personal mode with Bitwarden integration
- **oagmode**: Enterprise mode with custom CA bundle and Bitwarden
- **ptxmode**: Corporate mode with 1Password integration
- Always check mode with `{{- if (or .pmode .oagmode) }}` for Bitwarden-based modes
- New features requiring secrets must add checks for all three modes

### PowerShell Script Conventions

All PowerShell `.ps1.tmpl` files follow these patterns:

#### Comment-Based Help (Required for all public functions)
```powershell
<#
.SYNOPSIS
    Brief one-line description
.DESCRIPTION
    Detailed explanation
.PARAMETER ParamName
    Parameter description
.EXAMPLE
    FunctionName -Param value
.NOTES
    Author: Patrick Lewis
#>
```

#### Function Structure
```powershell
function Verb-Noun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$ParamName,

        [Parameter()]
        [switch]$SwitchParam
    )

    try {
        # implementation
    }
    catch {
        Write-Error "Failed to ...: $($_.Exception.Message)"
    }
}
```

- `[CmdletBinding()]` always immediately precedes `param()` — no blank lines between them
- Use `[ValidateNotNullOrEmpty()]` for required string parameters
- Use `[ValidateRange(min, max)]` for numeric parameters
- Use `[ValidateSet('val1', 'val2')]` for enum-style parameters
- Prefer `Write-Error` / `Write-Verbose` over `Write-Host` (except for user-facing messages)
- Use `$($_.Exception.Message)` for error message interpolation in catch blocks
- PascalCase for all function names and parameter names
- Wrap with OS guard when Windows/macOS only: `{{- if (or (eq .chezmoi.os "windows") (eq .chezmoi.os "darwin")) -}}`

#### PowerShell Profile Performance Guidelines
**CRITICAL**: Keep profile loading time under 700ms. Follow these patterns:
- **Lazy Loading**: Only load PSReadLine immediately; defer posh-git and Terminal-Icons
  - Use `Import-ModuleLazy` function for deferred module installation/import
  - Create `Enable-PoshGit` and `Enable-TerminalIcons` functions called on first use
- **Deferred Completions**: Register tab completers (Azure CLI, etc.) on first command use, not at startup
- **Minimal Error Handling**: Avoid try-catch blocks in hot paths; use simple conditionals
- **Direct Assignments**: Skip unnecessary wrapping (e.g., `[Console]::OutputEncoding = [Text.Encoding]::UTF8`)
- **Function-Level Loading**: Trigger lazy loads inside command functions (gs, ga, gc, gp, ll)
- **Attribute Syntax**: Always place `[CmdletBinding()]` immediately before `param()` block
- **Streamlined Loops**: Use simple array iteration for script loading, not hashtable iterations with verbose logging
- **Performance testing**: Run `Measure-Command { . $PROFILE }` after PowerShell profile changes to verify load time stays under 700ms

### Shell Script Conventions (`.sh.tmpl` files)

All shell scripts follow these patterns:

```sh
{{ if eq .chezmoi.os "linux" -}}
#!/bin/sh

set -e  # Exit on error

echo "[-] Section description [-]"

# Check if tool is available before using
if ! command -v tool >/dev/null 2>&1; then
    echo "Error: tool not found"
    exit 1
fi

# Check if already installed before installing
if ! dpkg -l "package" >/dev/null 2>&1; then
    sudo apt install -y "package"
fi

echo "[-] Section completed [-]"
{{ end -}}
```

- Use `#!/bin/sh` (POSIX) for hooks; use `#!/bin/sh` with `set -e` for install scripts
- Always wrap content with platform OS guard: `{{ if eq .chezmoi.os "linux" -}}`
- Use `echo "[-] description [-]"` pattern for section headings in output
- Use `command -v name >/dev/null 2>&1` to check for tool availability
- Check for existing installations before installing (idempotency)
- Redirect stderr to `/dev/null` for checks: `>/dev/null 2>&1`
- Use `type bw >/dev/null 2>&1 && exit` for early-exit guards in hooks

### Package Management System
- `.chezmoidata/packages.yaml` defines packages for each platform (winget, brew, dnf, apt)
- Mode-specific packages in nested sections (e.g., `packages.windows.pmode.winget`)
- Installation scripts in `.chezmoiscripts/{platform}/` execute based on changes
- Package installation uses `run_onchange_` prefix for conditional execution
- YAML structure: `packages.{os}.{manager}` and `packages.{os}.{mode}.{manager}`
- Extensions structure: `extensions.{os}.vscode`

### External Dependencies (`.chezmoiexternal.toml`)

Standard pattern for binary downloads:

```toml
[".local/bin/toolname"]
    type = "file"
    url = "https://github.com/org/repo/releases/latest/download/tool-{{ .chezmoi.os }}-{{ .chezmoi.arch }}"
    executable = true
    refreshPeriod = "168h"

[".local/bin/toolname-from-archive"]
    type = "archive-file"
    url = "https://github.com/org/repo/releases/download/v1.0/tool-{{ .chezmoi.os }}-{{ .chezmoi.arch }}.tar.gz"
    executable = true
    refreshPeriod = "168h"
    path = "tool-binary-name"

[".local/share/toolname-dir"]
    type = "archive"
    url = "https://example.com/archive.zip"
    refreshPeriod = "168h"
    exact = true
    stripComponents = 1
```

- Standard `refreshPeriod` is `"168h"` (weekly) for all external tools
- Always use `{{ .chezmoi.os }}` and `{{ .chezmoi.arch }}` for cross-platform URLs
- Use `exact = true` for directories that should be fully managed
- Wrap entire file in `{{- if eq .chezmoi.os "linux" }}` / `{{- if eq .chezmoi.os "windows" }}` guards
- Linux tools go under `~/.local/bin/`; themes go under `~/.poshthemes/`

## Critical Integration Points

### Password Manager Integration
- Pre-hooks in `.chezmoi.toml.tmpl` install password managers based on mode
- Bitwarden (`bw`) for pmode/oagmode
- 1Password (`op`) for ptxmode
- `cz` wrapper handles authentication (`$env:BW_SESSION` on PowerShell, `$BW_SESSION` on bash)
- Access Bitwarden fields: `{{ (bitwardenFields "item" "chezmoi").fieldname.value | quote }}`
- Access 1Password fields: `{{ (onepasswordItemFields "chezmoi").fieldname.value | quote }}`

### SSH Configuration
- Mode-dependent SSH agent setup (Bitwarden SSH agent for oagmode)
- Platform-specific SSH command paths in git config
- WSL uses Windows OpenSSH: `/mnt/c/WINDOWS/System32/OpenSSH/ssh.exe`
- oagmode uses Bitwarden SSH socket: `~/.bitwarden-ssh-agent.sock`
- WSL bash aliases redirect `ssh` and `ssh-add` to Windows `.exe` variants

### Shell Customization
- oh-my-posh with `night-owl` theme across all platforms
  - Linux/bash: `~/.poshthemes/night-owl.omp.json`
  - macOS/zsh: `$(brew --prefix oh-my-posh)/themes/night-owl.omp.json`
- Shell enhancement tools: `direnv`, `zoxide` (initialized with `eval "$(tool init shell)"`)
- `eza` replaces `ls` with `--group-directories-first --icons` flags; falls back to `ls --color=auto`
- `bat` replaces `cat` when available

### Terraform Version Management
- `dot_terraform-version.tmpl` pins tfenv to version `1.5.7`
- tfenv installed to `~/.local/bin/tfenv/` and added to PATH in profile files

## When Working on This Codebase
- Always test template changes across multiple platforms using `chezmoi diff`
- New features should respect the mode system — add mode checks where appropriate
- External tool updates go in `.chezmoiexternal.toml` with proper platform conditionals
- PowerShell scripts need Windows/macOS OS guards: `{{- if (or (eq .chezmoi.os "windows") (eq .chezmoi.os "darwin")) -}}`
- Shell scripts need Linux OS guards: `{{ if eq .chezmoi.os "linux" -}}`
- Never add secrets or credentials directly in templates — always use Bitwarden or 1Password template functions
- New packages belong in `.chezmoidata/packages.yaml` under the appropriate platform and mode section
- New VS Code extensions belong in `.chezmoidata/packages.yaml` under `extensions.{platform}.vscode`
- Keep shell scripts POSIX-compatible (`#!/bin/sh`) unless bash-specific features are required
