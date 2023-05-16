#!/usr/bin/env bash

set -euo pipefail

sh <(curl -L https://nixos.org/nix/install) --no-daemon
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# nix profile install --profile bootstrap nixpkgs#nix nixpkgs#git nixpkgs#git-crypt nixpkgs#gnupg
# nix-env --switch-profile bootstrap
# <do nasty things with git-crypt>
# nix-env --switch-profile ~/.local/state/nix/profiles/profile 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
"$SCRIPT_DIR"/switch.sh "$@"
