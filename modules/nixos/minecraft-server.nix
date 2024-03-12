# https://tailscale.com/blog/nixos-minecraft/

{ self, pkgs, ... }:

with self.inputs;
{
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers = {
      terralith20 = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_20_2;
        symlinks = {
          mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
            Terralith = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/qFd4s3fV/Terralith_1.20.2_v2.4.7.jar"; sha512 = "10ef14d491b920390229f34615323cd6a28b16a27cd29c5472349b642df3fd7bb70f6a14f6b78cc18153e6d7445967d0436ad8ac14e14a75f3d02a8e63b4da5c"; };
#            Cristel = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/cl223EMc/versions/LRFIdFuW/cristellib-1.1.4-fabric.jar"; sha512 = "2fd41c8ad8f1d4c883371673d2d9bacd52ae1e69119679ce02a0016b192925cabab9956ebae5bff9fc10ace7d5c4d7d1e79b6b7653f33aa53fd54e9bfe10435b"; };
            FabricAPI = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/ZI1BEw1i/fabric-api-0.90.4%2B1.20.2.jar"; sha512 = "31f3b114c2b37bae5419e162d212bc7aaffcad9df122e94d2a461e9f92d694af6ab5b7a2d9684f6df75dd7df5c7b0d2ce8df2046fd6bccd8dd4fa0fa3a3727de"; };
#            UnfixedSeeds = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/BMKSAGRn/versions/TDwrdjSl/unfixed-seeds-1.0.2.jar"; sha512 = "20c397c2defccdaa498b2b89d602b297ef933dda38282a5ccea36871e249d723d678657717e0c65932396e2549f531512482d1dec6d3d5c297f9fd5ff3a2284a"; };
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
