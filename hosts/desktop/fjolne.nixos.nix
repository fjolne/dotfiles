{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./clojure.nix ./web.nix ./android.nix ];

  # programs.keychain = {
  #   keys = [ "id_ed25519" "yoko_vm_rsa" "yoko_ama.pem" ];
  # };

  services.gpg-agent.enable = false;
}
