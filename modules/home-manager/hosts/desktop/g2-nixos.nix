{ config, pkgs, ... }:

{
  imports = [ ./nixos.nix ];

  home.packages = with pkgs; [
    ((pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: {
      src = (builtins.fetchTarball {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
        sha256 = "0vklckqw8hc74ggqr7snqidzf0h7366sdxq72rrvpl7kz1nh3kxs";
      });
      version = "latest";
    }))
    (pkgs.writeShellScriptBin "code" ''
      code-insiders "$@"
    '')

    pcsx2
    retroarchFull
  ];
}
