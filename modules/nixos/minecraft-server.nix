# https://tailscale.com/blog/nixos-minecraft/

{ pkgs, inputs, ... }:

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers = {
      terralith = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_18_2-0_14_9;
        symlinks = {
          mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
            Terralith = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/aYOzrVFZ/Terralith_1.18.2_v2.2.4.jar"; sha512 = "7fea7c2c5007101a82c0f8d952c074603866c1ca4fa72dadd870c6616eae75c4959d7d1586ca0e5a72a49e99813b2ba120005328f8cacc41e603692e393b8d4f"; };
            Cristel = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/cl223EMc/versions/HocdgthH/cristellib-fabric-1.0.0.jar"; sha512 = "633b73cab4bf3f175209c27b2fc49fca81409e2d502d372666ae3d087bf55f98790cf2a39d9b6eb49a818704d21473aaee439bd2f66030d2c098705f89b61bc4"; };
            FabricAPI = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/95QMsRyb/fabric-api-0.76.0%2B1.18.2.jar"; sha512 = "4c8b663ac80a58baa9d6e2589c32dab822d199439cf7dde5421891242c1b49ef1040e3cbf68c97d58e51094d15435f7593c83febd1ffb4942af3ae7cbe828218"; };
            UnfixedSeeds = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/BMKSAGRn/versions/TDwrdjSl/unfixed-seeds-1.0.2.jar"; sha512 = "20c397c2defccdaa498b2b89d602b297ef933dda38282a5ccea36871e249d723d678657717e0c65932396e2549f531512482d1dec6d3d5c297f9fd5ff3a2284a"; };
          });
        };

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
    };
  };
}
