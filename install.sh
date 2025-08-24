#!/bin/sh

set -e # Exit on error

echo "Installing dotfiles using chezmoi..."

if [ ! "$(command -v chezmoi)" ]; then
    echo "chezmoi not found, installing..."
    bin_dir="$HOME/.local/bin"
    chezmoi="$bin_dir/chezmoi"
    
    # Create bin directory if it doesn't exist
    mkdir -p "$bin_dir"
    
    if [ "$(command -v curl)" ]; then
        echo "Downloading chezmoi using curl..."
        sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
    elif [ "$(command -v wget)" ]; then
        echo "Downloading chezmoi using wget..."
        sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
    else
        echo "Error: To install chezmoi, you must have curl or wget installed." >&2
        exit 1
    fi
else
    echo "chezmoi found, using existing installation"
    chezmoi=chezmoi
fi

echo "Initializing dotfiles from locus313/dotfiles..."

# Replace current process with chezmoi init
exec "$chezmoi" init --apply locus313
