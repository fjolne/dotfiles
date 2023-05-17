{ config, pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    openssh
  ];

  programs.keychain.enable = lib.mkForce false; # pass SSH_AUTH_SOCK from the host
}
