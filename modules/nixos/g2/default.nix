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

  services.teeworlds = {
    enable = true;
    openPorts = true;
    name = "fjolne-world";
    extraOptions = [
      "sv_map dm1"
      "sv_gametype dm"
    ];
  };
}
