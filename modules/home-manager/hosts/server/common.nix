{ lib, config, pkgs, ... }:

with lib;
{
  imports = [ ../base ];

  programs.keychain = {
    enable = true;
    inheritType = "local-once";
  };
}
