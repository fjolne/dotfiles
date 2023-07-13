{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    (pkgs.writeShellScript "mosh-server" ''
      export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
      exec ${pkgs.mosh}/bin/mosh-server "$@"
    '')
  ];

  programs.bash = {
    profileExtra = ''
      export LANG=en_US.utf-8
      export LC_ALL=en_US.utf-8
      export LC_CTYPE=en_US.utf-8
      export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
    '';
  };
}
