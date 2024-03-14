{ utils, ... }:

{
  imports = [ ./common.nix ];

  programs.ssh = {
    extraConfig = utils.readSecretFile ./ssh_config;
  };
}
