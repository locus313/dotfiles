if (-Not (Get-Command op -ErrorAction SilentlyContinue)) {

    winget install -e --id 1password-cli

}
