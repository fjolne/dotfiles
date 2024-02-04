# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ pkgs, lib, ... }:

with lib.hm.gvariant;

rec {
  home.packages = with pkgs.gnomeExtensions; [
    pop-shell
    workspace-matrix
    vitals
  ];

  dconf.settings = {
    "org/gnome/shell".enabled-extensions = map (extension: extension.extensionUuid) home.packages;
    "org/gnome/shell".disabled-extensions = [ ];

    "org/gnome/mutter" = {
      check-alive-timeout = 0;
    };

    "org/gnome/control-center" = {
      last-panel = "keyboard";
      window-state = mkTuple [ 980 640 ];
    };

    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "xkb" "ru" ]) ];
      xkb-options = [ "grp:menu_toggle" ];
    };

    "org/gnome/desktop/interface" = {
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      # gtk-theme = "Yaru-dark";
      # icon-theme = "Yaru";
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "org-telegram-desktop" ];
    };

    "org/gnome/desktop/notifications/application/org-telegram-desktop" = {
      application-id = "org.telegram.desktop.desktop";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/nautilus/preferences" = {
      migrated-gtk-settings = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
    };

    "org/gnome/shell/world-clocks" = {
      locations = "@av []";
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super><Control>c";
      command = "google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland --force-dark-mode";
      iname = "Chrome";
    };


    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super><Control>e";
      command = "code --enable-features=UseOzonePlatform --ozone-platform=wayland";
      iname = "Code";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super><Control>t";
      command = "kitty";
      iname = "Console";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Super><Control>b";
      command = "google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland --force-dark-mode chrome-extension://nngceckbapebfimnlniiiahkandclblb/popup/index.html?uilocation=popout";
      iname = "Bitwarden";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      binding = "<Super><Alt><Control><Shift>s";
      command = "systemctl suspend";
      iname = "Suspend";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      binding = "<Super><Alt><Control><Shift>l";
      command = "loginctl lock-session";
      iname = "Lock";
    };
  };
}
