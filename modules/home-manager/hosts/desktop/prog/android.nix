{ config, pkgs, ... }:

{
  home.shellAliases = {
    adb-root = ''sh -c "kill -9 $(pgrep adb); sudo $ANDROID_SDK_ROOT/platform-tools/adb root"'';
  };
}
