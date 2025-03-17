{ self, pkgs, pkgs-unstable, pkgs-unstable-vscode, pkgs-unstable-cursor, lib, ... }:

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
    google-chrome
    pkgs-unstable-vscode.telegram-desktop
    gnome.gnome-tweaks
    self.packages.x86_64-linux.code-cursor

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
