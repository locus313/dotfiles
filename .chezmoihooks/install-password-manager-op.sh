#!/bin/sh

# Exit immediately if op is already installed in ~/.local/bin
# (don't rely on $PATH — it may not include ~/.local/bin on first run)
if [ -x "$HOME/.local/bin/op" ]; then
    exit
fi

# Create ~/.local/bin if it doesn't exist
mkdir -p ~/.local/bin

case "$(uname -s)" in
Darwin)
    # Set up Homebrew in PATH for non-interactive shells (Apple Silicon: /opt/homebrew, Intel: /usr/local)
    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if command -v brew >/dev/null 2>&1; then
        echo "Installing 1Password CLI via Homebrew..."
        brew install --cask 1password-cli
        # Symlink into ~/.local/bin so chezmoi can find it via a fixed path
        ln -sf "$(brew --prefix)/bin/op" ~/.local/bin/op
        echo "1Password CLI installed successfully"
        exit 0
    fi
    ;;
esac

# Fetch the latest 1Password CLI version from the AgileBits update API
echo "Fetching latest 1Password CLI version..."
OP_VERSION=$(curl -s "https://app-updates.agilebits.com/check/1/0/CLI2/en/2.0.0/N" | grep -o '"version":"[^"]*"' | grep -o '[0-9][0-9.]*')

if [ -z "$OP_VERSION" ]; then
    echo "Error: Failed to determine latest 1Password CLI version"
    exit 1
fi

echo "Installing 1Password CLI v${OP_VERSION}..."

case "$(uname -s)" in
Darwin)
    DOWNLOAD_URL="https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_darwin_universal_v${OP_VERSION}.zip"
    ;;
Linux)
    case "$(uname -m)" in
        x86_64)
            DOWNLOAD_URL="https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_amd64_v${OP_VERSION}.zip"
            ;;
        aarch64|arm64)
            DOWNLOAD_URL="https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_arm64_v${OP_VERSION}.zip"
            ;;
        *)
            echo "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
    ;;
*)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

if ! curl -fL "$DOWNLOAD_URL" -o /tmp/op.zip; then
    echo "Error: Failed to download 1Password CLI from ${DOWNLOAD_URL}"
    rm -f /tmp/op.zip
    exit 1
fi

if ! unzip -t /tmp/op.zip >/dev/null 2>&1; then
    echo "Error: Downloaded file is not a valid zip archive"
    rm -f /tmp/op.zip
    exit 1
fi

# Extract only the op binary directly into ~/.local/bin
unzip -q /tmp/op.zip op -d ~/.local/bin/
chmod +x ~/.local/bin/op

# Clean up
rm -f /tmp/op.zip

echo "1Password CLI v${OP_VERSION} installed successfully"
