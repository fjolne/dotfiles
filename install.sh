#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install ${NO_SYSTEMD:+linux --init none} --no-confirm
bash

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
nix run home-manager/master -- switch -b bak --flake "$SCRIPT_DIR${1:+#$1}"
EOF
