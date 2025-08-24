#!/bin/sh

# Exit immediately if password-manager-binary is already in $PATH
type bw >/dev/null 2>&1 && exit

# Create bin directory if it doesn't exist
mkdir -p ~/.local/bin

case "$(uname -s)" in
Darwin)
    echo "Downloading Bitwarden CLI for macOS..."
    curl -L https://vault.bitwarden.com/download/?app=cli\&platform=macos -o /tmp/bw.zip
    ;;
Linux)
    echo "Downloading Bitwarden CLI for Linux..."
    curl -L https://vault.bitwarden.com/download/?app=cli\&platform=linux -o /tmp/bw.zip
    ;;
*)
    echo "Error: Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

# Check if download was successful
if [ ! -f /tmp/bw.zip ]; then
    echo "Error: Failed to download Bitwarden CLI"
    exit 1
fi

echo "Installing Bitwarden CLI..."
unzip -q /tmp/bw.zip -d ~/.local/bin
chmod +x ~/.local/bin/bw

# Clean up
rm -f /tmp/bw.zip

echo "Bitwarden CLI installed successfully"

# Note: Uncomment the following line if you want bash completion
# bw completion --shell bash > ~/.bash_completion.d/bw
