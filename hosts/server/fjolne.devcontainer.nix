{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.git = {
    enabled = false;
  };
}
