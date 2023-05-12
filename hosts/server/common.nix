{ config, pkgs, ... }:

{
  imports = [ ../common/common.nix ];

  # programs.ssh.extraConfig = builtins.readFile ./ssh_config;

  home.packages = [
    (pkgs.writeShellScriptBin "rersync" ''
      while [ $? -ne 0 ] ; do
          timeout 240 rsync --partial "$@"
      done
    '')
  ];
}
