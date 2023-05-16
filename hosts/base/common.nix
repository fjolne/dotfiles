{ config, pkgs, user, host, lib, ... }:

with lib;
{
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "22.11";
  };
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    lf
    bottom
    ripgrep
    fd
    less
    git-crypt
    pinentry

    nixpkgs-fmt
    nil

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
      ${lib.optionalString (!config.programs.mcfly.enable) ''
        PROMPT_COMMAND="''${PROMPT_COMMAND:+''${PROMPT_COMMAND/%;*( )};}history -a"
        HISTTIMEFORMAT='%F %T '
      ''}

      # Must C-d at least twice to close shell.
      export IGNOREEOF=1
    '';

    profileExtra = ''
      [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh
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

  programs.git = {
    enable = true;
    userName = "Oleg Martynov";
    userEmail = "fjolne.yngling@gmail.com";
    aliases = { };
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

  programs.ssh = {
    enable = true;
    # controlMaster = "auto";
    # controlPersist = "5m";
  };

  programs.keychain = {
    enable = true;
    keys = [ ];
  };

  programs.gpg = {
    enable = true;
    settings = { default-key = "D0CF68225E03419DBB5E266913B5BA0469A51BAE"; };
  };
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableExtraSocket = true;
    enableSshSupport = false;
    pinentryFlavor = "gtk2";
  };

  systemd.user.startServices = "sd-switch";
}
