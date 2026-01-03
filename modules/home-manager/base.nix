{ config, pkgs, pkgs-unstable, username, lib, ... }:

{
  imports = [
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bottom
    delta
    fd
    jq
    just
    less
    nil
    nixpkgs-fmt
    pkgs-unstable.nodejs_20
    pinentry
    ripgrep
    tree
    unzip
    neovim

    (pkgs.writeShellScriptBin "," ''nix run nixpkgs#$1 -- "''${@:2}"'')
    (pkgs.writeShellScriptBin ",," ''nix shell nixpkgs#$1'')
  ];

  home.sessionVariables = {
    TERM = "xterm-256color";
    VISUAL = "code";
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
    PAGER = "less -FiSwX";
    BROWSER = "google-chrome-stable";
  };

  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  home.shellAliases = {
    "sctl" = "systemctl --user";
    "jctl" = "journalctl --user";
    "fish-direnv" = "direnv exec / fish";
    "cat" = "bat -pp";
    "ll" = "ls -l";
    "lla" = "ls -la";
    "llt" = "tree -C";
    "vim" = "nvim";
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      set -gx TERM xterm-256color
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

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"

      bind -n S-Left  previous-window
      bind -n S-Right next-window

      bind -n M-S-Left  select-pane -L
      bind -n M-S-Right select-pane -R
      bind -n M-S-Up    select-pane -U
      bind -n M-S-Down  select-pane -D
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 24 * 60 * 60 * 1000; # 1 day
      aws = { disabled = true; };
    };
  };

  programs.bat = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Oleg Martynov";
    userEmail = "fjolne.yngling@gmail.com";
    aliases = {
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
    lfs.enable = true;
    extraConfig = {
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
    # controlMaster = "auto";
    # controlPersist = "5m";
  };

  systemd.user.startServices = "sd-switch";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.lf = {
    enable = true;
    keybindings = {
      e = "$vim $f";
      E = "$code $f";
      I = "$bat -p $f";
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
