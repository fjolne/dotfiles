switch:
	sudo nixos-rebuild --install-bootloader switch --flake .

switch-hm:
	nix run home-manager/master -- switch --flake .

reload-gpg:
	-pkill -f gpg-agent
	-pkill -f pinentry
	systemctl --user restart gpg-agent{.socket,-extra.socket,-ssh.socket}
