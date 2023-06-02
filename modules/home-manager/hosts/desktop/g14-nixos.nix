{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./clojure.nix ./web.nix ./android.nix ./gnome ];

  programs.keychain = {
    enable = false;
  };


  home.packages = with pkgs; [
    google-chrome
    gnome.gnome-tweaks
    tdesktop
    wl-clipboard
    ((pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: {
      src = (builtins.fetchTarball {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
        sha256 = "1ddr9fjlp4sk176b96c4i2qv5wzksjr5m929k3czncr6jfqsf6c3";
      });
      version = "latest";
    }))
    (pkgs.writeShellScriptBin "code" ''
      code-insiders "$@"
    '')
    
    # games
    minecraft
    heroic
  ];

  services.gpg-agent.enable = false;
}
