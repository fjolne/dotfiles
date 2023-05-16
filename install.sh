#!/usr/bin/env bash
set -euo pipefail

# install nix
sh <(curl -L https://nixos.org/nix/install) --no-daemon
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
. ~/.nix-profile/etc/profile.d/nix.sh

# install minimal stuff required
nix shell nixpkgs#git nixpkgs#git-crypt nixpkgs#gnupg nixpkgs#pinentry-gtk2

if [[ "$CLONE" == true ]]; then
    git clone https://github.com/fjolne/dotfiles && cd dotfiles
    install -d -m700 -o $USER -g $USER ~/.gnupg \
    && printf "grab\npinentry-program $(which pinentry)" > ~/.gnupg/gpg-agent.conf
    gpg --import
    git-crypt unlock
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
"$SCRIPT_DIR"/switch.sh "$@"