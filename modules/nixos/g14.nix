{ ... }:

{
  networking.hostName = "g14-nixos";

  users.users.gamer = {
    isNormalUser = true;
    description = "Games and stuff";
    extraGroups = [ "networkmanager" ];
  };
}
