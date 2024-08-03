#!/bin/sh

# exit immediately if password-manager-binary is already in $PATH
type bw >/dev/null 2>&1 && exit

case "$(uname -s)" in
Darwin)
    curl -L https://vault.bitwarden.com/download/?app=cli\&platform=macos -o /tmp/bw.zip
    ;;
Linux)
    curl -L https://vault.bitwarden.com/download/?app=cli\&platform=linux -o /tmp/bw.zip
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac

unzip /tmp/bw.zip -d ~/.local/bin
# bw completion --shell zsh > ~/.zfunc/_bw
