{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./clojure.nix ./web.nix ./android.nix ./gnome ];

  programs.keychain = {
    enable = false;
  };


  home.packages = with pkgs; [
    gnome.gnome-tweaks
    tdesktop
    wl-clipboard
  ];

  services.gpg-agent.enable = false;
}
