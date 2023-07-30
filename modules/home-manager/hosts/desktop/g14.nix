{ config, pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  programs.bash.enable = lib.mkForce false;
  programs.direnv.enableNushellIntegration = false;
  programs.nushell = {
    enable = true;
    extraConfig = ''
      let-env config = {
        show_banner: false,
        menus: [],
        keybindings: [],
        hooks: {
          env_change: {
            PWD: [{
              code: "
                let direnv = (direnv exec / direnv export json | from json)
                let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
                $direnv | load-env
              "
            }]
          }
        }
      }

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

      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/git/git-completions.nu *
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu *
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/cargo/cargo-completions.nu *
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/poetry/poetry-completions.nu *
    '';
  };
  programs.zoxide.enable = true;
}
