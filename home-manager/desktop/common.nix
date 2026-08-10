{ pkgs, pkgs-self, pkgs-unstable, lib, ... }:

{
  imports = [ ../base.nix ./gnome.nix ];

  home.packages = with pkgs; [
    # desktop apps
    google-chrome
    pkgs-unstable.telegram-desktop
    pkgs-self.claude-desktop
    gnome-tweaks

    # terminal apps
    wl-clipboard
    xclip

    # fonts
    nerd-fonts.iosevka
  ];

  fonts.fontconfig.enable = true;
  services.gpg-agent.enable = false;
}
