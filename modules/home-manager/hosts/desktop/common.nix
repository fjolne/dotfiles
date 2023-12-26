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
  };

  home.packages = with pkgs; [
    unstable.google-chrome
    gnome.gnome-tweaks
    unstable.tdesktop
    wl-clipboard
    python312
    asciinema
    mosh
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];

  fonts.fontconfig.enable = true;
  services.gpg-agent.enable = false;

  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      window_padding_width = 2;
    };
    keybindings = {
      "ctrl+shift+enter" = "new_window_with_cwd";
    };
    theme = "Gruvbox Dark";
    font = {
      name = "IosevkaNerdFont";
      size = 12;
    };
  };
}
