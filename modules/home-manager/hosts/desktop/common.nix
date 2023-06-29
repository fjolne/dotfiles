{ config, pkgs, lib, ... }:

with lib;
{
  imports = [ ../base/common.nix ];

  # programs.ssh.extraConfig = utils.readSecretFile ./ssh_config;
  programs.ssh = {
    serverAliveInterval = 60;
    serverAliveCountMax = 30;
    extraConfig = utils.readSecretFile ./ssh_config;
  };

  programs.keychain = {
    inheritType = "local-once";
  };
}
