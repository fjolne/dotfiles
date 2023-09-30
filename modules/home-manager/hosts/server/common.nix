{ lib, config, pkgs, ... }:

with lib;
{
  imports = [ ../base ];

  programs.ssh.extraConfig = utils.readSecretFile ./ssh_config;

  programs.keychain = {
    inheritType = "local-once";
  };
}
