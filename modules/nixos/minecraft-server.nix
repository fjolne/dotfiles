# https://tailscale.com/blog/nixos-minecraft/

{ pkgs, inputs, ... }:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://github.com/Misterio77/Modpack/raw/0.2.9/pack.toml";
    packHash = "sha256-L5RiSktqtSQBDecVfGj1iDaXV+E90zrNEcf4jtsg+wk=";
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers.servers.cool-modpack = {
    enable = true;
    package = pkgs.fabricServers.fabric-1_18_2-0_14_9;
    symlinks = {
      "mods" = "${modpack}/mods";
    };

    eula = true;
    openFirewall = true;
    declarative = true;

    serverProperties = {
      server-port = 25565;
      gamemode = "survival";
      motd = "modz";
      max-players = 2;
      level-seed = "789645678";
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
