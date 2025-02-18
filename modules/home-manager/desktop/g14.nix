{ username, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [ ./common.nix ];

  programs.ssh.enable = lib.mkForce false;
  systemd.user.tmpfiles.rules = [
    "L /home/${username}/.ssh/config - - - - /home/${username}/dotfiles/modules/home-manager/desktop/ssh_config"
  ];

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
    pkgs-unstable.godot_4
    pkgs-unstable.reaper
    pkgs-unstable.helm
    pkgs-unstable.dbeaver-bin
  ];
}
