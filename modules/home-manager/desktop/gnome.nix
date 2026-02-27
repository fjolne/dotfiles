{ pkgs, pkgs-unstable, ... }:
let
  paperwm = pkgs-unstable.gnomeExtensions.paperwm.overrideAttrs (_: {
    version = "145";
    src = pkgs.fetchzip {
      name = "paperwm-145.zip";
      url = "https://extensions.gnome.org/download-extension/paperwm@paperwm.github.com.shell-extension.zip?version_tag=68525";
      hash = "sha256-V0bEHC557t0pGHf5aMMZhq16nmiXqr7DImOj5a3btS4=";
      stripRoot = false;
    };
  });

  vitals = pkgs-unstable.gnomeExtensions.vitals.overrideAttrs (_: {
    version = "73";
    src = pkgs.fetchzip {
      name = "vitals-73.zip";
      url = "https://extensions.gnome.org/download-extension/Vitals@CoreCoding.com.shell-extension.zip?version_tag=64741";
      hash = "sha256-0cvFXTa2UUu44IqbFI1a13zGJuZ9ymfqdCZMAyGKgPc=";
      stripRoot = false;
    };
  });

  gnomeExtensions = [
    paperwm
    vitals
  ];
in
{
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

  home.packages = gnomeExtensions;
  dconf.settings = {
    "org/gnome/shell".enabled-extensions = map (extension: extension.extensionUuid) gnomeExtensions;
    "org/gnome/shell".disabled-extensions = [ ];
  };

  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
