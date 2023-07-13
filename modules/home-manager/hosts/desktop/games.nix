{ config, pkgs, ... }:

{
  imports = [];

  programs.bash = {
    initExtra = ''
      export WINEARCH=win64
      export WINEPREFIX=$HOME/.wine-battlenet
    '';
  };

  home.packages = with pkgs; [
    google-chrome

    minecraft
    prismlauncher
    mcrcon
    heroic
    (wineWowPackages.full.override {
      wineRelease = "staging";
      mingwSupport = true;
    })
    winetricks
    lutris
  ];
}
