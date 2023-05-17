#!/usr/bin/env bash
set -euo pipefail

# install nix
sh <(curl -L https://nixos.org/nix/install) --no-daemon
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
. ~/.nix-profile/etc/profile.d/nix.sh

if [[ "${CLONE:-}" == true ]]; then
    echo "Paste your private (passhprase-protected) GPG key:"
    key=$(cat) nix shell nixpkgs#git nixpkgs#git-crypt nixpkgs#gnupg nixpkgs#pinentry-gtk2 <<"EOF"
    git clone https://github.com/fjolne/dotfiles && cd dotfiles
    install -d -m700 -o $USER -g $USER ~/.gnupg \
    && printf "grab\npinentry-program $(which pinentry)" > ~/.gnupg/gpg-agent.conf
    gpg --import <<< "$key"
    git-crypt unlock
EOF
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
nix shell nixpkgs#git nixpkgs#git-crypt nixpkgs#gnupg nixpkgs#pinentry-gtk2 <<EOF
"$SCRIPT_DIR/switch.sh" "$@"
EOF