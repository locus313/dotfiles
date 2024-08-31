if (-Not (Get-Command bw -ErrorAction SilentlyContinue)) {

    winget install -e --id Bitwarden.CLI

}
