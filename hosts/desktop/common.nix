{ config, pkgs, lib, ... }:

with lib;
{
  imports = [ ../base/common.nix ];

  programs.ssh.extraConfig = utils.readSecretFile ./ssh_config;

  home.shellAliases = {
    hm-switch = "~/dotfiles/switch.sh";
  };
}
