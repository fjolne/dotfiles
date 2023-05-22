nixos-switch:
	sudo nixos-rebuild --install-bootloader switch --flake .

home-switch:
	nix run home-manager/master -- switch --flake .

reload-gpg:
	-pkill -f gpg-agent
	-pkill -f pinentry
	systemctl --user restart gpg-agent{.socket,-extra.socket,-ssh.socket}

sync-dconf:
	dconf dump / | nix run nixpkgs#dconf2nix -- --verbose > modules/home-manager/hosts/desktop/gnome/dconf.nix
