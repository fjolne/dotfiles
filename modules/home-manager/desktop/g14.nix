{ username, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [ ./common.nix ./ghostty.nix ];

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
  home.sessionVariables.SSH_AUTH_SOCK = lib.mkForce "$XDG_RUNTIME_DIR/ssh-agent";
  programs.fish.interactiveShellInit = lib.mkAfter ''
    # Keep shells pinned to system ssh-agent when GNOME keyring exports its own socket.
    set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent
  '';

  home.packages = with pkgs;[
    openssh
    # pkgs-unstable.dbeaver-bin
    # pkgs-unstable.prismlauncher
    # pkgs-unstable.mcrcon
  ];
}
