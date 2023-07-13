{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };
}
