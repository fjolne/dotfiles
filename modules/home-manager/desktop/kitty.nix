{ config, pkgs-unstable, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in

{
  home.packages = [ pkgs-unstable.kitty ];

  xdg.configFile."kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/kitty";
}
