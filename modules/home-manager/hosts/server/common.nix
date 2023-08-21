{ lib, config, pkgs, ... }:

with lib;
{
  imports = [ ../base ];

  programs.ssh.extraConfig = utils.readSecretFile ./ssh_config;

  programs.keychain = {
    inheritType = "any-once";
    keys = [ ];
  };
}
