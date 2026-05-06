{ config, pkgs-unstable, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in

{
  home.packages = [
    pkgs-unstable.kitty
    (pkgs-unstable.writeShellScriptBin "icat" ''
      exec ${pkgs-unstable.kitty}/bin/kitty icat "$@"
    '')
  ];

  xdg.configFile."kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/kitty";
}
