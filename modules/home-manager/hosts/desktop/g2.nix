{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    vscode

    pcsx2
    retroarchFull
  ];
}
