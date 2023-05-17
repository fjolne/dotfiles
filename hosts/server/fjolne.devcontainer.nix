{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    openssh
  ];

  programs.git.enabled = false;
  programs.keychain.enabled = false; # pass SSH_AUTH_SOCK from the host
}
