{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./clojure.nix ./web.nix ./android.nix ./gnome ];

  # programs.keychain = {
  #   keys = [ "id_ed25519" "yoko_vm_rsa" "yoko_ama.pem" ];
  # };


  home.packages = with pkgs; [
    gnome.gnome-tweaks
    tdesktop
  ];

  services.gpg-agent.enable = false;
}
