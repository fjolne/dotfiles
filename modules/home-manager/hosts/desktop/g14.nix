{ config, pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  programs.bash.enable = lib.mkForce false;
  programs.nushell = {
    enable = true;
    extraConfig = ''
      let-env config = { show_banner: false }

      cat $"($env.HOME)/.nix-profile/etc/profile.d/hm-session-vars.sh"
      | lines
      | where $it =~ ^export
      | str replace "export " ""
      | split column =
      | update column2 { |it| ^bash -c $"echo -n ($it.column2)" | str join }
      | transpose -r -d
      | load-env

      def ll [] { ls -l | select uid mode name type size modified target | sort-by type name -i }
      def lla [] { ls -la | select uid mode name type size modified target | sort-by type name -i }
    '';
  };
}
