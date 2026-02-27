{ self, pkgs, pkgs-unstable, lib, ... }:

{
  imports = [ ../base.nix ./gnome.nix ./kitty.nix ];

  programs.ssh.matchBlocks."*" = {
    serverAliveInterval = 60;
    serverAliveCountMax = 30;
  };

  home.packages = with pkgs; [
    # desktop apps
    google-chrome
    pkgs-unstable.telegram-desktop
    gnome-tweaks
    self.packages.x86_64-linux.code-cursor

    # terminal apps
    wl-clipboard
    xclip
    python312
    asciinema
    mosh

    # fonts
    nerd-fonts.iosevka
  ];

  fonts.fontconfig.enable = true;
  services.gpg-agent.enable = false;
}
