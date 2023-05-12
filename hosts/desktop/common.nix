{ config, pkgs, ... }:

{
  imports = [ ../common/common.nix ];

  programs.ssh.extraConfig = builtins.readFile ./ssh_config;
}
