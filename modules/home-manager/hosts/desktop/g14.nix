{ config, pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  programs.bash.enable = lib.mkForce false;
  programs.nushell = {
    enable = true;
    extraConfig = ''
      let-env config = { show_banner: false }
      def ll [] { ls -l | select uid mode name type size modified target | sort-by type name -i }
      def lla [] { ls -la | select uid mode name type size modified target | sort-by type name -i }
    '';
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };
}
