{ config, pkgs, username, lib, ... }:

with lib;
{
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    jq
    lf
    bottom
    ripgrep
    fd
    less
    git-crypt
    pinentry
    just
    mosh

    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];

  fonts.fontconfig.enable = true;

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
    plugins = with pkgs.tmuxPlugins; [
      fingers
    ];
  };

  home.sessionVariables = {
    TERM = "xterm-256color";
    VISUAL = "code";
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
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
    '';

    profileExtra = ''
      [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh
    '';
  };

  home.shellAliases = {
    # FIXME
    # "mo" = "mosh --server=/home/ec2-user/.local/bin/mosh-server";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 24 * 60 * 60 * 1000; # 1 day
      aws = { disabled = true; };
    };
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
    };
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

  programs.keychain = {
    enable = mkDefault true;
    keys = [ ];
  };

  programs.gpg = {
    enable = true;
    settings = { default-key = "D0CF68225E03419DBB5E266913B5BA0469A51BAE"; };
  };
  services.gpg-agent = {
    enable = mkDefault true;
    defaultCacheTtl = 1800;
    enableExtraSocket = true;
    enableSshSupport = false;
    pinentryFlavor = "gtk2";
  };

  systemd.user.startServices = "sd-switch";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
