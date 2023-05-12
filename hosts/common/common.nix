{ config, pkgs, user, lib, ... }:

{
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "22.11";
  };
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.lf
    pkgs.bottom
    pkgs.ripgrep
    pkgs.less
    pkgs.openssh

    pkgs.nixpkgs-fmt
    pkgs.nil

    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.file = {
    ".tmux.conf".source = ./tmux.conf;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    TERM = "xterm-256color";
    VISUAL = "code";
    EDITOR = "nvim";
  };

  programs.bash = {
    enable = true;

    shellOptions =
      lib.mkOptionDefault [ "cdspell" "dirspell" "histreedit" "histverify" ];

    historyFileSize = 500000;
    historySize = 500000;

    historyControl = [ "erasedups" "ignorespace" ];

    historyIgnore =
      [ "l" "x" "exit" "bg" "fg" "history" "poweroff" "ls" "cd" ".." "..." ];

    # Need to be after starship init since it overwrites PROMPT_COMMAND.
    initExtra = lib.mkAfter ''
      [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh

      ${lib.optionalString (!config.programs.mcfly.enable) ''
        PROMPT_COMMAND="''${PROMPT_COMMAND:+''${PROMPT_COMMAND/%;*( )};}history -a"
        HISTTIMEFORMAT='%F %T '
      ''}

      # Must C-d at least twice to close shell.
      export IGNOREEOF=1
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.starship = {
    enable = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    fileWidgetCommand = "${pkgs.fd}/bin/fd --type f";
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
    defaultOptions = [ "--border" "--inline-info" ];
  };

  programs.ssh = {
    enable = true;
    # controlMaster = "auto";
    # controlPersist = "5m";
  };

  programs.keychain = {
    enable = true;
    keys = [ "id_rsa" ];
  };

  programs.git = {
    enable = true;
    userName = "Oleg Martynov";
    userEmail = "fjolne.yngling@gmail.com";
    aliases = {
      count = "rev-list --all --count";
      snapshot =
        ''!git stash save "snapshot: $(date)" && git stash apply "stash@{0}"'';
    };
    difftastic = {
      enable = true;
      display = "inline";
    };
    extraConfig = {
      core.whitespace = "trailing-space,space-before-tab";
      merge.conflictstyle = "diff3";
      pull.ff = "only";
      rebase.autoStash = true;
      init.defaultBranch = "main";
      # rerere.enabled = true;
    };
  };

  # systemd.user.startServices = "sd-switch";
}
