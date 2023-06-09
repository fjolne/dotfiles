# https://tailscale.com/blog/nixos-minecraft/

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
      white-list = true;
      enable-rcon = false;
      # "rcon.password" = "camelot";
    };
    whitelist = {
      "fjolne" = "bd49ca96-e31a-4be7-8a15-0046ab5e2833";
      "nbstrva" = "d1c16aa0-beca-4641-94d8-f512ea08161b";
    };
  };
}
