#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

sh <(curl -L https://nixos.org/nix/install) --no-daemon
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
. ~/.nix-profile/etc/profile.d/nix.sh

if [[ "${CLONE:-}" == true ]]; then
    echo "Paste your private (passhprase-protected) GPG key:"
    key=$(cat) nix shell nixpkgs#git nixpkgs#git-crypt nixpkgs#gnupg nixpkgs#pinentry-gtk2 <<"EOF"
    git clone https://github.com/fjolne/dotfiles && cd dotfiles
    install -d -m700 -o $USER -g $USER ~/.gnupg \
    && printf "grab\npinentry-program $(which pinentry)" > ~/.gnupg/gpg-agent.conf
    export GPG_TTY=$(tty)
    gpg --import <<< "$key"
    git-crypt unlock
EOF
    SCRIPT_DIR="$SCRIPT_DIR/dotfiles"
fi

nix shell nixpkgs#git nixpkgs#git-crypt <<EOF
"$SCRIPT_DIR/switch.sh" "$@"
EOF
