#!/bin/sh

# exit immediately if 1password cli is already in $PATH
type op >/dev/null 2>&1 && exit

# Create ~/.local/bin if it doesn't exist
mkdir -p ~/.local/bin

case "$(uname -s)" in
Darwin)
    # For macOS, download the universal binary
    curl -L https://cache.agilebits.com/dist/1P/op2/pkg/v2.29.0/op_darwin_universal_v2.29.0.zip -o /tmp/op.zip
    ;;
Linux)
    # Detect architecture for Linux
    case "$(uname -m)" in
        x86_64)
            curl -L https://cache.agilebits.com/dist/1P/op2/pkg/v2.29.0/op_linux_amd64_v2.29.0.zip -o /tmp/op.zip
            ;;
        aarch64|arm64)
            curl -L https://cache.agilebits.com/dist/1P/op2/pkg/v2.29.0/op_linux_arm64_v2.29.0.zip -o /tmp/op.zip
            ;;
        *)
            echo "unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
    ;;
*)
    echo "unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

# Extract and install
unzip /tmp/op.zip -d /tmp/
mv /tmp/op ~/.local/bin/
chmod +x ~/.local/bin/op

# Clean up
rm -f /tmp/op.zip /tmp/op

echo "1Password CLI installed successfully"
