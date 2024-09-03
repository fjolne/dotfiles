{ self, pkgs, pkgs-unstable, pkgs-unstable-vscode, lib, ... }:

with lib;
{
  imports = [ ../base.nix ./gnome.nix ./kitty.nix ];

  programs.ssh = {
    serverAliveInterval = 60;
    serverAliveCountMax = 30;
  };

  programs.vscode = {
    enable = true;
    package = pkgs-unstable-vscode.vscode;
  };

  home.packages = with pkgs; [
    # desktop apps
    pkgs-unstable.google-chrome
    pkgs-unstable-vscode.telegram-desktop
    pkgs-unstable.zulip
    pkgs-unstable.calibre
    pkgs-unstable.rclone
    pkgs-unstable.obsidian
    gnome.gnome-tweaks
    self.packages.${pkgs.hostPlatform.system}.cursor

    # terminal apps
    wl-clipboard
    xclip
    python312
    asciinema
    mosh

    # fonts
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];

  fonts.fontconfig.enable = true;
  services.gpg-agent.enable = false;
}
