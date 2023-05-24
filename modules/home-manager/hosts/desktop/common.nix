{ config, pkgs, lib, ... }:

with lib;
{
  imports = [ ../base/common.nix ];

  programs.ssh.extraConfig = utils.readSecretFile ./ssh_config;

  programs.keychain = {
    inheritType = "local-once";
  };
}
