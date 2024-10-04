# (Initially) generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;
{
  dconf.settings = {
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

    "org/gnome/desktop/wm/preferences".num-workspaces = 9;
    "org/gnome/shell/keybindings" = lib.listToAttrs
      (map (i: { name = "switch-to-application-${toString i}"; value = [ ]; })
        (lib.range 1 9));
    "org/gnome/desktop/wm/keybindings" = (lib.listToAttrs
      (map (i: { name = "switch-to-workspace-${toString i}"; value = [ "<Super>${toString i}" ]; })
        (lib.range 1 9))) // (lib.listToAttrs
      (map (i: { name = "move-to-workspace-${toString i}"; value = [ "<Super><Shift>${toString i}" ]; })
        (lib.range 1 9))) // {
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
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super><Control>c";
      command = "google-chrome-stable --force-dark-mode";
      iname = "Chrome";
    };


    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super><Control>e";
      command = "cursor";
      iname = "Cursor";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super><Control>t";
      command = "kitty";
      iname = "Console";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Super><Control>b";
      command = "google-chrome-stable --force-dark-mode chrome-extension://nngceckbapebfimnlniiiahkandclblb/popup/index.html?uilocation=popout";
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

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
      binding = "<Super><Control>v";
      command = "kitty --session ~/src/fjolne/kitty-sessions/kitty-subs-vertical.session";
      iname = "kitty subs vertical";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
      binding = "<Super><Control>h";
      command = "kitty --session ~/src/fjolne/kitty-sessions/kitty-subs-tabs.session";
      iname = "kitty subs tabs";
    };
  };
}
