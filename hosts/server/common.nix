{ lib, config, pkgs, ... }:

with lib;
{
  imports = [ ../common/common.nix ];

  programs.ssh.extraConfig = utils.readSecretFile ./ssh_config;

  programs.keychain = {
    keys = [ "id_rsa" ];
  };

  home.packages = [
    (pkgs.writeShellScriptBin "rersync" ''
      while [ $? -ne 0 ] ; do
          timeout 240 rsync --partial "$@"
      done
    '')
  ];
}
