{ pkgs-unstable, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs-unstable.ghostty;
    settings = {
      font-family = "Iosevka Nerd Font";
      font-size = 12;
      theme = "GruvboxDark";
      window-padding-x = 2;
      window-padding-y = 2;
    };
  };
}
