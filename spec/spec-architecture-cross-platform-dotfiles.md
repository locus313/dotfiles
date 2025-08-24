---
title: Cross-Platform Dotfiles Management System Architecture
version: 1.0
date_created: 2025-08-24
last_updated: 2025-08-24
owner: Patrick Lewis (@locus313)
tags: [architecture, infrastructure, chezmoi, dotfiles, cross-platform, templating]
---

# Introduction

This specification defines the architecture and requirements for a sophisticated cross-platform dotfiles management system that provides seamless configuration deployment across Windows, Linux, and macOS environments using chezmoi as the core templating and deployment engine.

## 1. Purpose & Scope

This specification defines the architecture, requirements, and operational patterns for a cross-platform dotfiles management system that:

- Enables consistent development environment configuration across Windows, Linux (including WSL), and macOS
- Provides multi-mode operation for personal, enterprise, and corporate contexts
- Integrates password managers for secure credential management
- Automates installation and configuration of essential development tools
- Uses Go templating for platform-specific and mode-aware configurations

**Intended Audience**: DevOps engineers, system administrators, developers implementing dotfiles management systems, and AI systems tasked with maintaining or extending this architecture.

**Assumptions**: Users have basic familiarity with command-line interfaces, Git version control, and shell environments.

## 2. Definitions

- **chezmoi**: A tool for managing dotfiles across multiple diverse machines, securely
- **Dotfiles**: Configuration files for Unix-like systems that typically start with a dot (.)
- **Template**: Go template files with `.tmpl` extension that generate platform-specific configurations
- **Mode**: Operational context (pmode/oagmode/ptxmode) that controls feature enablement
- **WSL**: Windows Subsystem for Linux - Linux compatibility layer for Windows
- **CA Bundle**: Custom Certificate Authority bundle for enterprise environments
- **External Tool**: Third-party binary or tool managed via `.chezmoiexternal.toml`
- **Hook**: Script executed at specific points in the chezmoi lifecycle
- **Private File**: Configuration file excluded from version control (prefixed with `private_`)

## 3. Requirements, Constraints & Guidelines

### Core Architecture Requirements

- **REQ-001**: The system MUST support Windows, Linux, and macOS platforms with identical functionality
- **REQ-002**: The system MUST detect WSL environments and apply appropriate configurations
- **REQ-003**: The system MUST provide three distinct operational modes: pmode, oagmode, and ptxmode
- **REQ-004**: All configuration files MUST be generated from Go templates with platform and mode conditionals
- **REQ-005**: The system MUST automatically install chezmoi if not present during initial setup
- **REQ-006**: External tools MUST be managed through `.chezmoiexternal.toml` with weekly refresh cycles

### Security Requirements

- **SEC-001**: Private files (SSH keys, certificates) MUST be excluded from version control
- **SEC-002**: Password manager integration MUST be enforced based on operational mode
- **SEC-003**: Enterprise CA bundles MUST be configurable for corporate environments
- **SEC-004**: All external tool downloads MUST use HTTPS and verify checksums where available

### Platform-Specific Requirements

- **PLT-001**: Windows installations MUST support both PowerShell 5.1 and PowerShell 7+
- **PLT-002**: WSL environments MUST integrate with Windows OpenSSH for git operations
- **PLT-003**: Linux installations MUST support multiple package managers (apt, yum, pacman)
- **PLT-004**: macOS installations MUST integrate with Homebrew package manager

### Template Requirements

- **TPL-001**: All template files MUST use `.tmpl` extension
- **TPL-002**: Templates MUST include platform detection using `{{ .chezmoi.os }}`
- **TPL-003**: WSL detection MUST use `{{ $wsl }}` variable pattern
- **TPL-004**: Mode-specific features MUST be gated by appropriate mode flags

### Constraints

- **CON-001**: External tool refresh period is fixed at 168 hours (weekly)
- **CON-002**: PowerShell scripts are restricted to Windows and WSL environments
- **CON-003**: SSH configuration must accommodate platform-specific OpenSSH paths
- **CON-004**: Git configuration must handle different line ending preferences per platform

### Guidelines

- **GUD-001**: New features SHOULD respect the existing mode system architecture
- **GUD-002**: Platform-specific code SHOULD be clearly documented and tested
- **GUD-003**: External dependencies SHOULD be minimized and well-justified
- **GUD-004**: Configuration templates SHOULD fail gracefully when data is missing

### Patterns

- **PAT-001**: Use `{{- if eq .chezmoi.os "windows" -}}` for Windows-specific code
- **PAT-002**: Use `{{- if .wsl }}` for WSL-specific configurations
- **PAT-003**: Use mode flags (`{{ .pmode }}`, `{{ .oagmode }}`, `{{ .ptxmode }}`) for feature gating
- **PAT-004**: Prefix private files with `private_` in chezmoi naming convention

## 4. Interfaces & Data Contracts

### Configuration Data Schema

```yaml
# .chezmoi.toml data structure
data:
  email: string          # Git commit email address
  name: string           # Git commit author name  
  pmode: boolean         # Personal mode flag
  oagmode: boolean       # Enterprise mode flag
  ptxmode: boolean       # Corporate mode flag
  wsl: boolean           # WSL environment detection (auto-calculated)
```

### External Tools Configuration

```toml
# .chezmoiexternal.toml structure
["target-path"]
  type = "file" | "archive"
  url = "https://..."
  executable = true | false
  refreshPeriod = "168h"
  exact = true | false      # For archives only
```

### Installation Script Interface

```bash
# Linux/macOS installation
curl -fsSL https://raw.githubusercontent.com/locus313/dotfiles/main/install.sh | sh

# Windows installation  
iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/locus313/dotfiles/main/install.ps1"))
```

### Mode-Aware Wrapper Interface

```powershell
# cz wrapper function
cz <chezmoi-command> [args...]
# Automatically handles Bitwarden session management
# Provides enhanced error handling and logging
```

## 5. Acceptance Criteria

- **AC-001**: Given a fresh system installation, When the installation script is executed, Then chezmoi and all dependencies SHALL be installed and configured
- **AC-002**: Given template files with platform conditionals, When `chezmoi apply` is executed, Then only platform-appropriate configurations SHALL be generated
- **AC-003**: Given a user selects pmode during setup, When configurations are applied, Then Bitwarden CLI SHALL be installed and available
- **AC-004**: Given a WSL environment, When git configuration is applied, Then Windows OpenSSH path SHALL be used for git operations
- **AC-005**: Given external tools configuration, When refresh period expires, Then tools SHALL be automatically updated to latest versions
- **AC-006**: Given private files in `private_dot_ssh/`, When repository is cloned, Then these files SHALL NOT be present in version control
- **AC-007**: Given multiple operational modes selected, When configuration is applied, Then all selected mode features SHALL be enabled
- **AC-008**: Given a template rendering error, When `chezmoi apply` is executed, Then the system SHALL provide clear error messages and fail gracefully

## 6. Test Automation Strategy

### Test Levels
- **Unit Testing**: Template rendering validation with mock data
- **Integration Testing**: End-to-end installation across all supported platforms
- **System Testing**: Multi-mode configuration validation in isolated environments

### Frameworks
- **Shell Testing**: bats-core for shell script testing
- **PowerShell Testing**: Pester framework for PowerShell script validation
- **Template Testing**: chezmoi's built-in `--dry-run` and `diff` capabilities
- **Container Testing**: Docker containers for isolated platform testing

### Test Data Management
- Mock user data for template rendering tests
- Isolated chezmoi configurations for each test scenario
- Temporary directories for filesystem operation testing
- Version-controlled test fixtures for expected outputs

### CI/CD Integration
- GitHub Actions workflows for multi-platform testing
- Matrix builds covering Windows, Linux, and macOS
- Automated installation script testing on fresh environments
- Template rendering validation on pull requests

### Coverage Requirements
- 100% coverage of all template conditional branches
- All installation scripts must be tested on target platforms
- External tool download and verification testing
- Mode-specific feature validation across all combinations

### Performance Testing
- Installation time benchmarking across platforms
- Template rendering performance with large configurations
- External tool download and refresh performance monitoring

## 7. Rationale & Context

### Architecture Decisions

**Chezmoi Selection**: Chosen for its robust templating system, cross-platform support, and active community. Provides better template capabilities than alternatives like GNU Stow or dotbot.

**Go Templates**: Leverages chezmoi's native Go template engine for powerful conditional logic and platform detection without external dependencies.

**Mode System**: Three-mode approach (personal/enterprise/corporate) addresses real-world deployment scenarios where feature sets must be restricted or enhanced based on organizational context.

**Password Manager Integration**: Bitwarden chosen for personal/enterprise modes due to open-source nature and CLI availability. 1Password selected for corporate mode due to enterprise features and SSO integration.

**External Tool Management**: Centralized management through `.chezmoiexternal.toml` ensures consistent tool versions and automatic updates while reducing manual maintenance overhead.

### Design Trade-offs

**Complexity vs. Flexibility**: The template-driven approach increases initial complexity but provides significant flexibility for multi-platform deployment.

**Security vs. Convenience**: Private file exclusion requires manual management but ensures sensitive data never enters version control.

**Performance vs. Freshness**: Weekly refresh cycles balance tool currency with network overhead and installation performance.

## 8. Dependencies & External Integrations

### External Systems
- **EXT-001**: GitHub - Source code hosting and release management for external tools
- **EXT-002**: Bitwarden/1Password - Password manager services for credential storage and SSH agent functionality

### Third-Party Services
- **SVC-001**: oh-my-posh releases - Prompt theming engine with cross-platform support
- **SVC-002**: Nerd Fonts releases - Programming fonts with icon support for enhanced terminal experience
- **SVC-003**: direnv releases - Environment variable management for project-specific settings
- **SVC-004**: aws-vault releases - AWS credential management and session handling

### Infrastructure Dependencies
- **INF-001**: Internet connectivity - Required for initial installation and external tool updates
- **INF-002**: Package managers - Platform-specific package managers (winget, apt, yum, brew) for dependency installation
- **INF-003**: Git - Version control system required for chezmoi source management

### Data Dependencies
- **DAT-001**: GitHub API - Release information for latest external tool versions
- **DAT-002**: User configuration data - Email, name, and mode preferences collected during setup
- **DAT-003**: Platform detection data - OS, architecture, and WSL environment information

### Technology Platform Dependencies
- **PLT-001**: PowerShell 5.1+ - Required for Windows script execution and module management
- **PLT-002**: Bash/Zsh - Required for Linux/macOS shell configuration and script execution
- **PLT-003**: chezmoi 2.0+ - Core templating and configuration management engine

### Compliance Dependencies
- **COM-001**: Enterprise CA requirements - Custom certificate bundle support for corporate environments
- **COM-002**: SSH key management - Platform-specific SSH agent integration for secure authentication

## 9. Examples & Edge Cases

### Platform Detection Example
```go
{{- if eq .chezmoi.os "windows" -}}
# Windows PowerShell configuration
$PSReadLineOptions = @{
    EditMode = "Emacs"
    HistorySearchCursorMovesToEnd = $true
}
{{- else -}}
# Unix shell configuration
export EDITOR=vim
export PAGER=less
{{- end }}
```

### Mode-Aware Feature Example
```go
{{- if .pmode }}
# Personal mode: Enable Bitwarden integration
export BW_SESSION=$(bw unlock --raw)
{{- else if .ptxmode }}
# Corporate mode: Enable 1Password integration  
eval $(op signin)
{{- end }}
```

### WSL Detection and Configuration
```go
{{- $wsl := (and (eq .chezmoi.os "linux") (.chezmoi.kernel.osrelease | lower | contains "microsoft")) -}}
{{- if $wsl }}
[core]
    # Use Windows OpenSSH in WSL
    sshCommand = /mnt/c/WINDOWS/System32/OpenSSH/ssh.exe
{{- end }}
```

### Edge Cases
- **Empty mode selection**: System must handle cases where no operational modes are selected
- **Network unavailable**: External tool downloads must fail gracefully with clear error messages
- **Missing dependencies**: Installation scripts must detect and install missing prerequisites
- **Permission errors**: SSH key installation must handle file permission requirements across platforms
- **Template data missing**: Configurations must provide sensible defaults when user data is incomplete

## 10. Validation Criteria

### Template Validation
- All template files must render without errors using `chezmoi execute-template`
- Platform conditionals must produce appropriate output for each supported OS
- Mode flags must correctly gate features based on user selection

### Installation Validation
- Fresh system installations must complete successfully on all supported platforms
- All external tools must be downloaded and verified for correct operation
- Password managers must be installed and available based on selected mode

### Configuration Validation
- Generated configuration files must be syntactically valid for their respective applications
- SSH configurations must successfully authenticate with remote systems
- Git configurations must support commit operations with correct author information

### Security Validation
- Private files must never appear in version control history
- Custom CA bundles must be properly configured when oagmode is enabled
- SSH agent integration must function correctly across all supported platforms

## 11. Related Specifications / Further Reading

- [chezmoi User Guide](https://chezmoi.io/user-guide/) - Official chezmoi documentation
- [Go Template Documentation](https://pkg.go.dev/text/template) - Go template syntax reference
- [Bitwarden CLI Documentation](https://bitwarden.com/help/cli/) - Password manager integration guide
- [1Password CLI Documentation](https://developer.1password.com/docs/cli/) - Corporate password manager reference
- [oh-my-posh Configuration](https://ohmyposh.dev/docs/) - Prompt theming engine documentation
- [PowerShell Profile Management](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles) - PowerShell configuration reference
