{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith pkgs;
in
{
  leafish = callPackage ./leafish { };
  bws = callPackage ./bws { };
  tic-80 = pkgs.xorg.callPackage ./tic-80 { };
  tic-80-pro = pkgs.xorg.callPackage ./tic-80 { withPro = true; };
  code-cursor = callPackage ./code-cursor { };
}
