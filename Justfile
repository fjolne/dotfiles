ps:
    nixos-version

home-switch target=".":
    nix run .#home-manager -- switch -b bak --flake {{target}}

nixos-switch target=".":
    sudo nixos-rebuild switch --flake {{target}}

# hard-reload gpg-agent
gpg-agent-switch:
    pkill -f gpg-agent || true
    pkill -f pinentry || true
    systemctl --user restart gpg-agent{,-extra,-ssh}.socket

# import private GPG key from stdin
gpg-import:
    #!/usr/bin/env bash
    set -xeuo pipefail
    if [[ ! -e ~/.gnupg/gpg-agent.conf ]]; then
        install -d -m700 -o "$(whoami)" -g "$(whoami)" ~/.gnupg
        echo -e "grab\npinentry-program $(which pinentry)" > ~/.gnupg/gpg-agent.conf
    fi
    cat | GPG_TTY=$(tty) gpg --import

# decrypt git-crypt files
crypt-unlock:
    git-crypt unlock
    nix store gc

