{ pkgs-unstable, ... }: rec {
  imports = [ ./dconf.nix ];

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
