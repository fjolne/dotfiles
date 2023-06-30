{ config, pkgs, ... }:

{
  imports = [ ./nixos.nix ];

  home.packages = with pkgs; [
    vscode

    pcsx2
    retroarchFull
  ];
}
