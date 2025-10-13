# Cross-Platform Dotfiles Management

[![GitHub stars](https://img.shields.io/github/stars/locus313/dotfiles?style=flat-square)](https://github.com/locus313/dotfiles/stargazers)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-000000?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0Ij4KICA8cGF0aCBmaWxsPSJ3aGl0ZSIgZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJ6Ii8+Cjwvc3ZnPgo=)](https://chezmoi.io)

> A sophisticated cross-platform dotfiles management system using chezmoi for seamless configuration deployment across Windows, Linux, and macOS environments.

This dotfiles repository provides a comprehensive solution for managing your development environment configuration across multiple platforms and contexts. Built with [chezmoi](https://chezmoi.io), it supports templating, multi-mode operation, and password manager integration for enterprise and personal use.

## Features

- **Cross-Platform Support**: Works seamlessly on Windows, Linux (including WSL), and macOS
- **Multi-Mode Operation**: Three operational modes (personal, enterprise, corporate) with different feature sets
- **Template-Driven**: Go template system for platform-specific and mode-aware configurations
- **Password Manager Integration**: Built-in support for Bitwarden and 1Password
- **Modern Shell Experience**: oh-my-posh theming with PowerShell modules and tab completion
- **Development Tools**: Pre-configured Git, SSH, and development environment setup
- **External Tool Management**: Automated installation and updates of essential tools

## Quick Start

Choose your platform and run the appropriate command:

### Linux / macOS
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/locus313/dotfiles/main/install.sh)"
```

### Windows
```powershell
iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/locus313/dotfiles/main/install.ps1"))
```

> **Note**: The installation script will automatically install chezmoi, git, and PowerShell (on Windows) if they're not already present.

## Configuration Modes

During initial setup, you'll be prompted to select operational modes that control which features are enabled:

### Personal Mode (`pmode`)
- Bitwarden CLI integration
- Personal development configurations
- Full feature set for individual use

### Enterprise Mode (`oagmode`)  
- Bitwarden CLI with custom CA bundle support
- Enterprise-specific configurations
- Corporate proxy and certificate handling

### Corporate Mode (`ptxmode`)
- 1Password CLI integration
- Corporate security policies
- Restricted feature set for managed environments

## Project Structure

### Core Configuration Files

| File | Target | Description |
|------|--------|-------------|
| [dot_gitconfig.tmpl](dot_gitconfig.tmpl) | `~/.gitconfig` | Git configuration with mode-aware settings and platform-specific SSH |
| [dot_bashrc.tmpl](dot_bashrc.tmpl) | `~/.bashrc` | Bash shell configuration with oh-my-posh integration |
| [dot_zshrc.tmpl](dot_zshrc.tmpl) | `~/.zshrc` | Zsh shell configuration with oh-my-posh theming |
| [dot_bash_aliases.tmpl](dot_bash_aliases.tmpl) | `~/.bash_aliases` | Bash aliases and shortcuts |
| [dot_profile.tmpl](dot_profile.tmpl) | `~/.profile` | Shell-agnostic profile configuration |
| [dot_zprofile.tmpl](dot_zprofile.tmpl) | `~/.zprofile` | Zsh profile configuration |
| [dot_terraform-version.tmpl](dot_terraform-version.tmpl) | `~/.terraform-version` | Terraform version configuration for tfenv |

### PowerShell Configurations

| File | Target | Description |
|------|--------|-------------|
| [Microsoft.PowerShell_profile.ps1.tmpl](Microsoft.PowerShell_profile.ps1.tmpl) | PowerShell profile | Main PowerShell profile with UTF-8 encoding and oh-my-posh |
| [Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl](Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl) | `~/Documents/PowerShell/` | Alternative PowerShell profile location |

### PowerShell Helper Scripts

| File | Description |
|------|-------------|
| [Scripts/Powershell/chezmoi.ps1.tmpl](Scripts/Powershell/chezmoi.ps1.tmpl) | Mode-aware chezmoi wrapper with Bitwarden session handling |
| [Scripts/Powershell/githelpers.ps1.tmpl](Scripts/Powershell/githelpers.ps1.tmpl) | Git shortcuts and aliases (`gs`, `ga`, `gc`, `gp`) |
| [Scripts/Powershell/linuxlike.ps1.tmpl](Scripts/Powershell/linuxlike.ps1.tmpl) | Linux-like command aliases for PowerShell |
| [Scripts/Powershell/psreadline.ps1.tmpl](Scripts/Powershell/psreadline.ps1.tmpl) | PSReadLine configuration for enhanced editing |
| [Scripts/Powershell/rename.ps1.tmpl](Scripts/Powershell/rename.ps1.tmpl) | File renaming utilities |
| [Scripts/Powershell/utils.ps1.tmpl](Scripts/Powershell/utils.ps1.tmpl) | General PowerShell utility functions |

### System Configuration

| Directory/File | Description |
|----------------|-------------|
| `.chezmoiscripts/` | Platform-specific setup scripts for automated installation |
| `.chezmoihooks/` | Password manager installation hooks |
| `private_dot_ssh/` | SSH configuration (private, not tracked in git) |
| `AppData/Roaming/` | Windows application data configurations |
| `.chezmoi.toml.tmpl` | Chezmoi configuration with mode prompts |
| `.chezmoiexternal.toml` | External tool management (oh-my-posh, direnv, aws-vault) |

## Key Features

### Intelligent Platform Detection
Templates automatically detect your platform and WSL environment:
```go
{{- if eq .chezmoi.os "windows" -}}
  # Windows-specific configuration
{{- end }}
{{- if .wsl }}
  # WSL-specific overrides  
{{- end }}
```

### Password Manager Integration
Automatic installation and authentication handling based on your selected mode:
- **Bitwarden**: For personal and enterprise modes
- **1Password**: For corporate environments
- Pre-hooks ensure password managers are available before configuration deployment

### Modern Shell Experience
- **oh-my-posh**: Beautiful, fast prompt with night-owl theme
- **PowerShell modules**: posh-git, Terminal-Icons, PsReadLine auto-installation
- **Tab completion**: Azure CLI and other tools
- **Git helpers**: Convenient shortcuts (`gs`, `ga`, `gc`, `gp`)

### External Tool Management
Automated download and updates (weekly refresh) of essential tools:
- oh-my-posh (prompt theme engine)
- direnv (environment variable management)
- aws-vault (AWS credential management)
- Nerd Fonts (programming fonts with icons)

## Usage

### Daily Workflow
Use the `cz` wrapper function for mode-aware chezmoi operations:
```bash
cz edit ~/.gitconfig    # Edit template files
cz apply               # Deploy configurations  
cz diff                # Preview changes
```

### Adding New Configurations
1. Add template files with `.tmpl` extension
2. Use platform and mode conditionals as needed
3. Test across platforms with `chezmoi diff`
4. Apply changes with `chezmoi apply`

### Managing Secrets
- SSH keys and certificates go in `private_dot_ssh/`
- Use password manager integration for sensitive data
- Private files are excluded from git automatically

## Platform-Specific Notes

### Windows
- Automatic PowerShell and Git installation via winget
- WSL detection and specific configuration handling
- Windows OpenSSH integration for git operations

### Linux/WSL
- Package manager detection and tool installation
- Font installation for terminal theming
- Development environment setup

### macOS
- Homebrew integration for package management
- macOS-specific configurations and optimizations

## Troubleshooting

### Common Issues

**New commands not found after installation**: Restart your shell session or reload your profile.

**Password manager authentication failures**: Ensure your selected mode matches your password manager setup.

**Template rendering errors**: Check that all required data variables are properly set in `.chezmoi.toml`.

### Getting Help
For issues specific to this dotfiles setup, check the template files and mode configurations. For chezmoi-specific problems, consult the [official documentation](https://chezmoi.io/docs/).

## Contributing

Contributions are welcome! When adding new features:
- Respect the mode system - add appropriate mode checks
- Test template changes across multiple platforms
- Update external tool versions in `.chezmoiexternal.toml` when needed
- Follow the existing naming conventions for template files

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
