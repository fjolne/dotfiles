{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.keychain = {
    enable = true;
    inheritType = "local-once";
    keys = [ ];
  };
}
