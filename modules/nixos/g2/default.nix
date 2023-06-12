{ ... }:

{
  imports = [ ../minecraft-server.nix ];
  networking.hostName = "g2-nixos";
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
