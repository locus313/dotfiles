#!/bin/sh

# exit immediately if 1password cli is already in $PATH
type op >/dev/null 2>&1 && exit

# Create ~/.local/bin if it doesn't exist
mkdir -p ~/.local/bin

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
    curl -L "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_darwin_universal_v${OP_VERSION}.zip" -o /tmp/op.zip
    ;;
Linux)
    case "$(uname -m)" in
        x86_64)
            curl -L "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_amd64_v${OP_VERSION}.zip" -o /tmp/op.zip
            ;;
        aarch64|arm64)
            curl -L "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_arm64_v${OP_VERSION}.zip" -o /tmp/op.zip
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

# Extract only the op binary directly into ~/.local/bin
unzip -q /tmp/op.zip op -d ~/.local/bin/
chmod +x ~/.local/bin/op

# Clean up
rm -f /tmp/op.zip

echo "1Password CLI v${OP_VERSION} installed successfully"
