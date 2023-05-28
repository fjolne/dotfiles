{
  description = "nix system configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , nixos-hardware
    , home-manager
    } @ inputs:
    let
      mkNixosConfig =
        { system ? "x86_64-linux"
        , nixpkgs ? inputs.nixpkgs
        , hardwareModules
        , baseModules ? [
            home-manager.nixosModules.home-manager
            ./modules/nixos
          ]
        , extraModules ? [ ]
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hardwareModules ++ extraModules;
          specialArgs = { inherit self inputs nixpkgs; };
        };
      mkHomeConfig =
        { username
        , system ? "x86_64-linux"
        , nixpkgs ? inputs.nixpkgs
        , baseModules ? [
            ./modules/home-manager
          ]
        , extraModules ? [ ]
        }:
        let
          lib = nixpkgs.lib.extend
            (final: prev: (import ./lib final) // home-manager.lib);
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit self inputs nixpkgs lib username; };
          modules = baseModules ++ extraModules;
        };
    in
    flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    {
      packages = import ./packages { inherit pkgs; };

      legacyPackages = {
        nixosConfigurations = {
          "g14-nixos" = mkNixosConfig {
            system = "x86_64-linux";
            hardwareModules = [
              ./modules/hardware/g14.nix
              nixos-hardware.nixosModules.asus-zephyrus-ga401
            ];
            extraModules = [ ];
          };
        };

        homeConfigurations = {
          "fjolne@g14-nixos" = mkHomeConfig {
            inherit system;
            username = "fjolne";
            extraModules = [ ./modules/home-manager/hosts/desktop/g14-nixos.nix ];
          };
          "fjolne@g14-fedora" = mkHomeConfig {
            inherit system;
            username = "fjolne";
            extraModules = [ ./modules/home-manager/hosts/desktop/g14-fedora.nix ];
          };
          "ec2-user@devcontainer" = mkHomeConfig {
            inherit system;
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/hosts/server/devcontainer.nix ];
          };
          "fjolne@vpc" = mkHomeConfig {
            inherit system;
            username = "fjolne";
            extraModules = [ ./modules/home-manager/hosts/server/vpc.nix ];
          };
          "ec2-user@vpc" = mkHomeConfig {
            inherit system;
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/hosts/server/vpc.nix ];
          };
        };
      };
    });
}
