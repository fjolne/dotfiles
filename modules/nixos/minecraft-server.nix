{ pkgs, ... }:

{
  services.minecraft-server = {
    enable = true;
    eula = true;
    package = pkgs.minecraftServers.vanilla-1-18;
    openFirewall = true;
    declarative = true;

    # see here for more info: https://minecraft.gamepedia.com/Server.properties#server.properties
    serverProperties = {
      server-port = 25565;
      gamemode = "survival";
      motd = "fjolne-missed-childhood";
      max-players = 2;
      level-seed = "10292992";

      enable-rcon = false;
      # "rcon.password" = "camelot";
    };
  };
}
