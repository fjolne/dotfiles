{
  description = "nix system configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , flake-utils
    , nixos-hardware
    , home-manager
    , ...
    } @ inputs:
    let
      mkNixosConfig = { system, hardwareModules, extraModules ? [ ] }:
        let
          baseModules = [
            home-manager.nixosModules.home-manager
            ./modules/nixos
          ];
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hardwareModules ++ extraModules;
          specialArgs = { inherit self inputs nixpkgs; };
        };
      mkHomeConfig = { pkgs, username, extraModules ? [ ] }:
        let
          baseModules = [ ];
          lib = nixpkgs.lib.extend
            (final: prev: (import ./lib final) // home-manager.lib);
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit self inputs nixpkgs lib username; };
          modules = baseModules ++ extraModules;
        };
    in
    flake-utils.lib.eachDefaultSystem (system:
    let
      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      pkgs = (nixpkgs.legacyPackages.${system}.extend unstableOverlay)
        // { config.allowUnfree = true; };
    in
    {
      packages = import ./packages { inherit pkgs; };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          git-crypt
          gnupg
          pinentry-gtk2
          unstable.nushell
          (pkgs.writeShellScriptBin "main" ''${./main.nu} "$@"'')

          nixpkgs-fmt
          nil
        ];
      };

      legacyPackages = {
        inherit (pkgs) home-manager;

        nixosConfigurations = {
          "g14-nixos" = mkNixosConfig {
            inherit system;
            hardwareModules = [
              ./modules/hardware/g14.nix
              nixos-hardware.nixosModules.asus-zephyrus-ga401
            ];
            extraModules = [ ./modules/nixos/g14 ];
          };
          "g2-nixos" = mkNixosConfig {
            inherit system;
            hardwareModules = [
              ./modules/hardware/g2.nix
            ];
            extraModules = [ ./modules/nixos/g2 ];
          };
        };

        homeConfigurations = {
          "fjolne@g14-nixos" = mkHomeConfig {
            inherit pkgs;
            username = "fjolne";
            extraModules = [ ./modules/home-manager/hosts/desktop/g14.nix ];
          };
          "gamer@g14-nixos" = mkHomeConfig {
            inherit pkgs;
            username = "gamer";
            extraModules = [ ./modules/home-manager/hosts/desktop/g14-gamer.nix ];
          };
          "fjolne@g2-nixos" = mkHomeConfig {
            inherit pkgs;
            username = "fjolne";
            extraModules = [ ./modules/home-manager/hosts/desktop/g2.nix ];
          };
          "ec2-user@devcontainer" = mkHomeConfig {
            inherit pkgs;
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/hosts/server/devcontainer.nix ];
          };
          "fjolne@vpc" = mkHomeConfig {
            inherit pkgs;
            username = "fjolne";
            extraModules = [ ./modules/home-manager/hosts/server/vpc.nix ];
          };
          "ilaut@vpc" = mkHomeConfig {
            inherit pkgs;
            username = "ilaut";
            extraModules = [ ./modules/home-manager/hosts/server/vpc.nix ];
          };
          "ec2-user@vpc" = mkHomeConfig {
            inherit pkgs;
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/hosts/server/vpc.nix ];
          };
        };
      };
    });
}
