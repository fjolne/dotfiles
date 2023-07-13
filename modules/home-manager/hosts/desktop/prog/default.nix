{ pkgs, ... }: {
  imports = [ ./clojure.nix ./web.nix ./android.nix ];
}
