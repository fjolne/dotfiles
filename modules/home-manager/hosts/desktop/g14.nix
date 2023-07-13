{ config, pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  programs.bash.enable = lib.mkForce false;
  programs.nushell = {
    enable = true;
    extraConfig = ''
      let-env config = { show_banner: false }
    '';
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };
}
