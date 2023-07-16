# Install

Install nix either with new [nix-installer](https://github.com/DeterminateSystems/nix-installer) or with [official one](https://nixos.org/download.html#download-nix):

```shell
# you may need to install core dependencies to be able to fetch and unpack the installer
#sudo apt install curl ca-certificates xz-utils

# good for multi-user installs
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# good for single-user installs (like containers)
sh <(curl -L https://nixos.org/nix/install) --no-daemon
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

Clone this repo and enter devshell:

```shell
nix shell nixpkgs#git
```

```shell
git clone https://github.com/fjolne/dotfiles
cd dotfiles
nix develop
```

Use `main` to setup the system:

```shell
# with secrets
main secrets import-gpg
main secrets unlock
main switch home .#fjolne@vpc

# without secrets
main switch home -s .#fjolne@vpc
```

# Inspirations

- https://github.com/kclejeune/system
- https://git.sr.ht/~rycee/configurations
