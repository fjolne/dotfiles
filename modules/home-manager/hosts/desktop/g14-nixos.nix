{ config, pkgs, ... }:

{
  imports = [ ./nixos.nix ];


  programs.vscode = {
    enable = true;
    package = ((pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: {
      pname = "vscode-insiders";
      src = (builtins.fetchTarball {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
        sha256 = "1ddr9fjlp4sk176b96c4i2qv5wzksjr5m929k3czncr6jfqsf6c3";
      });
      version = "latest";
    }));
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "code" ''
      code-insiders "$@"
    '')
  ];
}
