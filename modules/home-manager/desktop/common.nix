{ pkgs, pkgs-unstable, lib, ... }:

with lib;
{
  imports = [ ../base.nix ./gnome.nix ];

  programs.ssh = {
    serverAliveInterval = 60;
    serverAliveCountMax = 30;
  };

  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;
  };

  home.packages = with pkgs; [
    # desktop apps
    pkgs-unstable.google-chrome
    pkgs-unstable.telegram-desktop
    pkgs-unstable.zulip
    pkgs-unstable.calibre
    pkgs-unstable.rclone
    pkgs-unstable.obsidian
    gnome.gnome-tweaks

    # terminal apps
    wl-clipboard
    xclip
    python312
    asciinema
    mosh

    # fonts
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];

  fonts.fontconfig.enable = true;
  services.gpg-agent.enable = false;

  programs.kitty = {
    enable = true;
    package = pkgs-unstable.kitty;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      window_padding_width = 2;
      enabled_layouts = "vertical";
    };
    keybindings = {
      "ctrl+shift+enter" = "launch --type=tab --tab-title=current --location=after --cwd=current";
      "ctrl+shift+b" = "launch --allow-remote-control kitty +kitten broadcast --match-tab state:focused";
      "ctrl+shift+/" = "launch --type=window";
      "ctrl+shift+pageup" = "neighboring_window up";
      "ctrl+shift+pagedown" = "neighboring_window down";
    };
    theme = "Gruvbox Dark";
    font = {
      name = "IosevkaNerdFont";
      size = 12;
    };
  };
}
