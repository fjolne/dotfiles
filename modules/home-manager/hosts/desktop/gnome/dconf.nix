# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ pkgs, lib, ... }:

with lib.hm.gvariant;

rec {
  home.packages = with pkgs.gnomeExtensions; [
    pop-shell
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
      gtk-theme = "Yaru-dark";
      icon-theme = "Yaru";
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

    "org/gnome/shell" = {
      app-picker-layout = "[{'org.gnome.Extensions.desktop': <{'position': <0>}>, 'org.gnome.Contacts.desktop': <{'position': <1>}>, 'org.gnome.Weather.desktop': <{'position': <2>}>, 'org.gnome.clocks.desktop': <{'position': <3>}>, 'org.gnome.Maps.desktop': <{'position': <4>}>, 'firefox.desktop': <{'position': <5>}>, 'google-chrome.desktop': <{'position': <6>}>, 'org.gnome.Totem.desktop': <{'position': <7>}>, 'org.gnome.Calculator.desktop': <{'position': <8>}>, 'lf.desktop': <{'position': <9>}>, 'simple-scan.desktop': <{'position': <10>}>, 'org.gnome.Settings.desktop': <{'position': <11>}>, 'gnome-system-monitor.desktop': <{'position': <12>}>, 'cups.desktop': <{'position': <13>}>, 'nvim.desktop': <{'position': <14>}>, 'nixos-manual.desktop': <{'position': <15>}>, 'org.gnome.Characters.desktop': <{'position': <16>}>, 'yelp.desktop': <{'position': <17>}>, 'nvidia-settings.desktop': <{'position': <18>}>, 'org.gnome.Cheese.desktop': <{'position': <19>}>, 'org.gnome.font-viewer.desktop': <{'position': <20>}>, 'rog-control-center.desktop': <{'position': <21>}>, 'org.gnome.TextEditor.desktop': <{'position': <22>}>, 'org.gnome.Tour.desktop': <{'position': <23>}>}, {'code.desktop': <{'position': <0>}>, 'xterm.desktop': <{'position': <1>}>, 'org.telegram.desktop.desktop': <{'position': <2>}>, 'org.gnome.FileRoller.desktop': <{'position': <3>}>, 'org.gnome.Connections.desktop': <{'position': <4>}>, 'org.gnome.Console.desktop': <{'position': <5>}>, 'org.gnome.baobab.desktop': <{'position': <6>}>, 'org.gnome.DiskUtility.desktop': <{'position': <7>}>, 'org.gnome.Evince.desktop': <{'position': <8>}>, 'org.gnome.eog.desktop': <{'position': <9>}>, 'org.gnome.Logs.desktop': <{'position': <10>}>, 'org.gnome.seahorse.Application.desktop': <{'position': <11>}>, 'org.gnome.tweaks.desktop': <{'position': <12>}>}]";
    };

    "org/gnome/shell/world-clocks" = {
      locations = "@av []";
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Alt>w" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control><Super>c";
      command = "google-chrome-stable";
      iname = "Chrome";
    };


    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Control><Super>e";
      command = "code";
      iname = "Code";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Control><Super>t";
      command = "kitty";
      iname = "Console";
    };
  };
}
