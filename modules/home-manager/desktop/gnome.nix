{ pkgs-unstable, ... }: rec {
  imports = [ ./dconf.nix ];

  # Disable GNOME SSH agent components (unreliable - randomly set wrong SSH_AUTH_SOCK)
  # Using NixOS's programs.ssh.startAgent instead (systemd user service)
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';
  xdg.configFile."autostart/gcr-ssh-agent.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";

  home.packages = with pkgs-unstable.gnomeExtensions; [
    paperwm
    vitals
  ];
  dconf.settings = {
    "org/gnome/shell".enabled-extensions = map (extension: extension.extensionUuid) home.packages;
    "org/gnome/shell".disabled-extensions = [ ];
  };

  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
