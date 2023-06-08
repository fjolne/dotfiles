{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.bash = {
    profileExtra = ''
      export LANG=en_US.utf-8
      export LC_ALL=en_US.utf-8
      export LC_CTYPE=en_US.utf-8
      export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
    '';
  };
}
