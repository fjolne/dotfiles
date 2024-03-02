{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith pkgs;
in
{
  leafish = callPackage ./leafish { };
  bws = callPackage ./bws { };
  tic-80 = pkgs.xorg.callPackage ./tic-80 { };
}
