{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./clojure.nix ./web.nix ./android.nix ./gnome ];

  programs.bash = {
    initExtra = ''
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"

      export WINEARCH=win64
      export WINEPREFIX=$HOME/.wine-battlenet
    '';
  };

  programs.keychain = {
    enable = false;
  };

  home.packages = with pkgs; [
    google-chrome
    gnome.gnome-tweaks
    tdesktop
    wl-clipboard

    # games
    minecraft
    prismlauncher
    heroic
    (wineWowPackages.full.override {
      wineRelease = "staging";
      mingwSupport = true;
    })
    winetricks
    lutris

    # go
    go
    gopls
    delve
    go-tools

    asciinema
  ];

  services.gpg-agent.enable = false;

  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
    font = {
      name = "IosevkaNerdFont";
      size = 12;
    };
    extraConfig = ''
      window_padding_width 2
    '';
  };
}
