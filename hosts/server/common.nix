{ lib, config, pkgs, ... }:

with lib;
{
  imports = [ ../base/common.nix ];

  programs.ssh.extraConfig = utils.readSecretFile ./ssh_config;

  programs.keychain = {
    inheritType = "local-once";
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
