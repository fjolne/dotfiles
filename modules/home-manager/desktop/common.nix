{ self, pkgs, pkgs-unstable, lib, ... }:

{
  imports = [ ../base.nix ./gnome.nix ];

  home.packages = with pkgs; [
    # desktop apps
    google-chrome
    pkgs-unstable.telegram-desktop
    gnome-tweaks
    self.packages.x86_64-linux.code-cursor

    # terminal apps
    xclip

    # fonts
    nerd-fonts.iosevka
  ];

  fonts.fontconfig.enable = true;
  services.gpg-agent.enable = false;
}
