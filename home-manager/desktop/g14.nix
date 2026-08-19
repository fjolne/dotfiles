{ config, lib, pkgs, pkgs-self, pkgs-unstable, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
{
  imports = [ ./common.nix ];

  programs.ssh.enable = lib.mkForce false;
  home.file.".ssh/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/home-manager/desktop/ssh_config";

  programs.gpg = {
    enable = true;
    settings = { default-key = "D0CF68225E03419DBB5E266913B5BA0469A51BAE"; };
  };
  services.gpg-agent = {
    enable = lib.mkDefault true;
    defaultCacheTtl = 1800;
    enableExtraSocket = true;
    enableSshSupport = false;
  };

  home.packages = with pkgs;[
    openssh
    pkgs-self.chatgpt-desktop
    # pkgs-unstable.dbeaver-bin
    # pkgs-unstable.prismlauncher
    # pkgs-unstable.mcrcon
  ];
}
