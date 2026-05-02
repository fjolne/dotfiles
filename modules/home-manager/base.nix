{ config, pkgs, pkgs-unstable, username, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
  extraBinPaths = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];
  lfCopy = pkgs.writeShellScript "lf-copy" ''
    set -eu

    mode="$1"
    path="$2"

    case "$mode" in
      relative)
        path="$(${pkgs.coreutils}/bin/realpath --relative-to="''${LF_LAUNCH_DIR:-$PWD}" -- "$path")"
        ;;
      absolute)
        path="$(${pkgs.coreutils}/bin/realpath -- "$path")"
        ;;
      contents)
        ;;
      *)
        printf 'unknown copy mode: %s\n' "$mode" >&2
        exit 2
        ;;
    esac

    if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      if [ "$mode" = contents ]; then
        ${pkgs.coreutils}/bin/cat -- "$path" | ${pkgs.wl-clipboard}/bin/wl-copy
      else
        printf '%s' "$path" | ${pkgs.wl-clipboard}/bin/wl-copy
      fi
    elif [ -n "''${DISPLAY:-}" ]; then
      if [ "$mode" = contents ]; then
        ${pkgs.coreutils}/bin/cat -- "$path" | ${pkgs.xclip}/bin/xclip -selection clipboard
      else
        printf '%s' "$path" | ${pkgs.xclip}/bin/xclip -selection clipboard
      fi
    else
      printf 'no graphical clipboard available\n' >&2
      exit 1
    fi
  '';
in
{
  imports = [
    ./nvim.nix
    ./desktop/kitty.nix # used on servers to show images
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };
  programs.home-manager.enable = true;

  home.packages = (with pkgs; [
    vim
    tmux
    bottom
    delta
    fd
    jq
    just
    less
    ripgrep
    tree
    unzip
    (pkgs.writeShellScriptBin "," ''nix run nixpkgs#$1 -- "''${@:2}"'')
    (pkgs.writeShellScriptBin ",," ''nix shell nixpkgs#$1'')
  ]) ++ (with pkgs-unstable; [
    # use https://github.com/fjolne/flake for per-project deps
    nodejs
    python3 # cannot make an alias for python=`uv run` because it leads to inf recursion
  ]);

  home.sessionVariables = {
    EDITOR = "nvim";
    SUDO_EDITOR = "vim";
    PAGER = "less -iSw";
    BROWSER = "google-chrome-stable";
  };

  home.sessionPath = extraBinPaths;

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  xdg.configFile."tmux".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/tmux";

  home.shellAliases = {
    "sctl" = "systemctl --user";
    "jctl" = "journalctl --user";
    "fish-direnv" = "direnv exec / fish";
    "cat" = "bat -pp";
    "ll" = "ls -l";
    "lla" = "ls -la";
    "llt" = "tree -C";
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -l hm_extra_paths ${lib.concatStringsSep " " extraBinPaths}
      set -l current_path
      for path_entry in $PATH
        if not contains -- $path_entry $hm_extra_paths
          set current_path $current_path $path_entry
        end
      end
      set -gx PATH $hm_extra_paths $current_path

      set fish_greeting
      set -e VISUAL
      set -l runtime_dir "$XDG_RUNTIME_DIR"
      if test -z "$runtime_dir"
        set runtime_dir "/run/user/"(id -u)
      end
      if test -S "$runtime_dir/ssh-agent"
        set -gx SSH_AUTH_SOCK "$runtime_dir/ssh-agent"
      end
    '';
    plugins = [
      {
        name = "autopair";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
          sha256 = "sha256-qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
        };
      }
      {
        name = "replay";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "replay.fish";
          rev = "bd8e5b89ec78313538e747f0292fcaf631e87bd2";
          sha256 = "sha256-bM6+oAd/HXaVgpJMut8bwqO54Le33hwO9qet9paK1kY=";
        };
      }
    ];
  };

  programs.fzf = {
    enable = true;
    fileWidgetCommand = "${pkgs.fd}/bin/fd --type f";
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
    defaultOptions = [ "--border" "--inline-info" ];
  };

  programs.bash = {
    enable = false;

    shellOptions =
      lib.mkOptionDefault [ "cdspell" "dirspell" "histreedit" "histverify" ];

    historyFileSize = 500000;
    historySize = 500000;

    historyControl = [ "erasedups" "ignorespace" ];

    historyIgnore =
      [ "l" "x" "exit" "bg" "fg" "history" "poweroff" "ls" "cd" ".." "..." ];

    # Need to be after starship init since it overwrites PROMPT_COMMAND.
    initExtra = lib.mkAfter ''
      ${lib.optionalString (!config.programs.mcfly.enable) ''
        PROMPT_COMMAND="''${PROMPT_COMMAND:+''${PROMPT_COMMAND/%;*( )};}history -a"
        HISTTIMEFORMAT='%F %T '
      ''}
    '';

    profileExtra = ''
      [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 24 * 60 * 60 * 1000; # 1 day
      format = "$username$hostname$directory$git_branch$git_status\n$jobs$character";
      username.show_always = true;
      hostname.ssh_only = false;
      aws.disabled = true;
    };
  };

  programs.bat = {
    enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Oleg Martynov";
      user.email = "fjolne.yngling@gmail.com";
      alias = {
        s = "status";
        d = "diff";
        ds = "diff --staged";
        dt = "difftool";
        dts = "difftool --staged";
        c = "commit";
        a = "add -p";
        p = "pull --rebase --autostash";
        l = "log --stat";
        pl = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      };
      core.whitespace = "trailing-space,space-before-tab";
      core.editor = "nvim";
      merge.conflictstyle = "diff3";
      pull.ff = "only";
      rebase.autoStash = true;
      init.defaultBranch = "main";
      # rerere.enabled = true;

      diff.tool = "difftastic";
      difftool.prompt = false;
      difftool.difftastic.cmd = ''${pkgs.difftastic}/bin/difft "$LOCAL" "$REMOTE" --color auto --background light --display inline'';
      pager.difftool = true;
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "no";
      checkHostIP = true;
      compression = false;
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
      forwardAgent = false;
      forwardX11 = false;
      forwardX11Trusted = false;
      hashKnownHosts = false;
      identitiesOnly = false;
      serverAliveInterval = 60;
      serverAliveCountMax = 30;
      userKnownHostsFile = "~/.ssh/known_hosts";
    };
  };

  systemd.user.startServices = "sd-switch";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.lf = {
    enable = true;
    package = pkgs.writeShellScriptBin "lf" ''
      export LF_LAUNCH_DIR="$PWD"
      exec ${pkgs.lf}/bin/lf "$@"
    '';
    keybindings = {
      "<a-y>" = "$" + "${lfCopy} relative \"$f\"";
      I = "$bat -p --paging=always $f";
      "<a-Y>" = "$" + "${lfCopy} absolute \"$f\"";
      Y = "$" + "${lfCopy} contents \"$f\"";
      j = "$jq . $f | $PAGER";
      J = "$jq . $f | bat -p --paging=always -l json";
    };
    previewer.source = pkgs.writeShellScript "pv.sh" ''bat -pp --color always "$@"'';
  };

  programs.yazi = {
    enable = true;
    package = pkgs-unstable.yazi;
    keymap = {
      manager.prepend_keymap = [
        {
          on = "!";
          run = "shell \"$SHELL\" --block";
          desc = "Open shell here";
        }
      ];
    };
  };
}
