{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith pkgs;
in
{
  leafish = callPackage ./leafish { };
}
