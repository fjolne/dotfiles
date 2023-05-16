#!/usr/bin/env bash

set -euo pipefail

sh <(curl -L https://nixos.org/nix/install) --no-daemon
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
echo 'nix run nixpkgs#git-crypt -- "$@"' > ~/.local/bin/git-crypt && chmod u+x ~/.local/bin/git-crypt

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
"$SCRIPT_DIR"/switch.sh "$@"
