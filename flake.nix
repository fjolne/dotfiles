{
  description = "nix system configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , home-manager
    , ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.foldl'
          (
            acc: system:
            nixpkgs.lib.recursiveUpdate acc (
              nixpkgs.lib.mapAttrs (_: value: { "${system}" = value; }) (f system)
            )
          )
          { }
          systems;
    in
    forAllSystems (system:
    let
      pkgs-params = {
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron-25.9.0" ];
      };
      pkgs = import nixpkgs ({ inherit system; } // pkgs-params);
      pkgs-unstable = import nixpkgs-unstable ({ inherit system; } // pkgs-params);
      pkgs-self = self.packages.${system};

      mkNixosConfig = { hardwareModules, extraModules ? [ ] }:
        let
          baseModules = [
            ./nixos/configuration.nix
          ];
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hardwareModules ++ extraModules;
          specialArgs = { inherit self pkgs-self pkgs-unstable; };
        };

      mkHomeConfig = { username, extraModules ? [ ] }:
        let
          baseModules = [
          ];
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username pkgs-self pkgs-unstable; };
          modules = baseModules ++ extraModules;
        };
    in
    {
      packages = import ./packages { inherit pkgs; };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          git-crypt
          gnupg
          pinentry-gtk2
          nixpkgs-fmt
          nil
          just
        ];
      };

      legacyPackages = {
        inherit (pkgs) home-manager;

        nixosConfigurations = {
          "g14-nixos" = mkNixosConfig {
            hardwareModules = [
              ./hardware/g14.nix
              nixos-hardware.nixosModules.asus-zephyrus-ga401
            ];
            extraModules = [ ./nixos/g14.nix ];
          };
          "g2-nixos" = mkNixosConfig {
            hardwareModules = [
              ./hardware/g2.nix
            ];
            extraModules = [ ./nixos/g2.nix ];
          };
        };

        homeConfigurations = {
          "fjolne@g14-nixos" = mkHomeConfig {
            username = "fjolne";
            extraModules = [ ./home-manager/desktop/g14.nix ];
          };
          "gamer@g14-nixos" = mkHomeConfig {
            username = "gamer";
            extraModules = [ ./home-manager/desktop/g14-gamer.nix ];
          };
          "fjolne@g2-nixos" = mkHomeConfig {
            username = "fjolne";
            extraModules = [ ./home-manager/desktop/g2.nix ];
          };
          "ec2-user@nixos" = mkHomeConfig {
            username = "ec2-user";
            extraModules = [ ./home-manager/base.nix ];
          };
          "fjolne@nixos" = mkHomeConfig {
            username = "fjolne";
            extraModules = [ ./home-manager/base.nix ];
          };
          "piglet@nixos" = mkHomeConfig {
            username = "piglet";
            extraModules = [ ./home-manager/base.nix ];
          };
        };
      };
    });
}
