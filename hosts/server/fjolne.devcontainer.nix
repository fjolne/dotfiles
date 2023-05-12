{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    openssh
  ];

  programs.git = {
    enabled = false;
  };
}
