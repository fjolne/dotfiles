{ utils, lib, ... }:

{
  imports = [ ./common.nix ];

  programs.ssh = {
    extraConfig = utils.readSecretFile ./ssh_config;
  };

  programs.gpg = {
    enable = true;
    settings = { default-key = "D0CF68225E03419DBB5E266913B5BA0469A51BAE"; };
  };
  services.gpg-agent = {
    enable = lib.mkDefault true;
    defaultCacheTtl = 1800;
    enableExtraSocket = true;
    enableSshSupport = false;
    pinentryFlavor = "gtk2";
  };
}
