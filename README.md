# Install (anywhere?)
```shell
# pre-reqs for nix installer per se
#sudo apt install curl ca-certificates xz-utils

# install nix
sh <(curl -L https://nixos.org/nix/install) --no-daemon
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
. ~/.nix-profile/etc/profile.d/nix.sh

# install minimal stuff required
nix shell nixpkgs#git nixpkgs#git-crypt nixpkgs#gnupg nixpkgs#pinentry-gtk2

# import gpg key
install -d -m700 -o $USER -g $USER ~/.gnupg \
&& printf "grab\npinentry-program $(which pinentry)" > ~/.gnupg/gpg-agent.conf
gpg --import

# finith it
git clone https://github.com/fjolne/dotfiles && cd dotfiles
git-crypt unlock
./switch.sh
```