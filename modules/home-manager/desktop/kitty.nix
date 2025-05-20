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
      enabled_layouts = "vertical, horizontal, stack";
      disable_ligatures = "always";
    };
    keybindings = {
      "kitty_mod+enter" = "launch --type=tab --tab-title=current --location=after --cwd=current";
      "kitty_mod+b" = "launch --allow-remote-control kitty +kitten broadcast --match-tab state:focused";
      "kitty_mod+/" = "launch --location=hsplit";
      "kitty_mod+alt+/" = "launch --location=vsplit";
      "kitty_mod+f" = "toggle_layout stack";
      "kitty_mod+i" = "neighboring_window up";
      "kitty_mod+e" = "neighboring_window down";
      "kitty_mod+alt+left" = "neighboring_window left";
      "kitty_mod+alt+right" = "neighboring_window right";
    };
    theme = "Gruvbox Dark";
    font = {
      name = "Iosevka Nerd Font";
      size = 12;
    };
  };
}
