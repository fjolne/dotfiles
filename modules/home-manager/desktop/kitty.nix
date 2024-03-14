{ pkgs-unstable, ... }:

{
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
      "ctrl+shift+alt+up" = "neighboring_window up";
      "ctrl+shift+alt+down" = "neighboring_window down";
      "ctrl+shift+alt+left" = "neighboring_window left";
      "ctrl+shift+alt+right" = "neighboring_window right";
    };
    theme = "Gruvbox Dark";
    font = {
      name = "IosevkaNerdFont";
      size = 12;
    };
  };
}
