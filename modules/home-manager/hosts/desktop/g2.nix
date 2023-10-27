{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    pcsx2
    retroarchFull
    mcrcon
  ];
}
