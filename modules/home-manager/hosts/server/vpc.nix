{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.bash = {
    profileExtra = ''
      export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
    '';
  };
}
