{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./clojure.nix ./web.nix ./android.nix ];

}
