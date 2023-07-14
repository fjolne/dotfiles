{ config, pkgs, lib, ... }:

with lib;
{
  imports = [ ../base ./gnome ];

  programs.ssh = {
    serverAliveInterval = 60;
    serverAliveCountMax = 30;
    extraConfig = utils.readSecretFile ./ssh_config;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };

  home.packages = with pkgs; [
    google-chrome
    gnome.gnome-tweaks
    tdesktop
    wl-clipboard
    python312
    asciinema
  ];

  programs.keychain.enable = false;
  services.gpg-agent.enable = false;

  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
    font = {
      name = "IosevkaNerdFont";
      size = 12;
    };
    extraConfig = ''
      window_padding_width 2
    '';
  };
}
