#!/bin/sh

# Exit immediately if bw is already installed in ~/.local/bin
# (don't rely on $PATH — it may not include ~/.local/bin on first run)
if [ -x "$HOME/.local/bin/bw" ]; then
    exit
fi

# Create bin directory if it doesn't exist
mkdir -p ~/.local/bin

case "$(uname -s)" in
Darwin)
    if command -v brew >/dev/null 2>&1; then
        echo "Installing Bitwarden CLI via Homebrew..."
        brew install bitwarden-cli
        # Symlink into ~/.local/bin so chezmoi can find it via a fixed path
        ln -sf "$(brew --prefix)/bin/bw" ~/.local/bin/bw
    else
        echo "Downloading Bitwarden CLI for macOS..."
        curl -L "https://vault.bitwarden.com/download/?app=cli&platform=macos" -o /tmp/bw.zip
        if [ ! -f /tmp/bw.zip ]; then
            echo "Error: Failed to download Bitwarden CLI"
            exit 1
        fi
        unzip -q /tmp/bw.zip -d ~/.local/bin
        chmod +x ~/.local/bin/bw
        rm -f /tmp/bw.zip
    fi
    ;;
Linux)
    echo "Downloading Bitwarden CLI for Linux..."
    curl -L "https://vault.bitwarden.com/download/?app=cli&platform=linux" -o /tmp/bw.zip
    if [ ! -f /tmp/bw.zip ]; then
        echo "Error: Failed to download Bitwarden CLI"
        exit 1
    fi
    unzip -q /tmp/bw.zip -d ~/.local/bin
    chmod +x ~/.local/bin/bw
    rm -f /tmp/bw.zip
    ;;
*)
    echo "Error: Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

echo "Bitwarden CLI installed successfully"
