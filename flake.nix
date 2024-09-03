{
  description = "nix system configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable-vscode.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix.url = "github:nixos/nix/2.21.4";

    flake-utils.url = "github:numtide/flake-utils";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-ld-rs.url = "github:nix-community/nix-ld-rs";
    nix-ld-rs.inputs.nixpkgs.follows = "nixpkgs";
    nix-ld-rs.inputs.flake-utils.follows = "flake-utils";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim/nixos-24.05";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixpkgs-unstable-vscode
    , flake-utils
    , nixos-hardware
    , home-manager
    , nixvim
    , ...
    }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs-params = {
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron-25.9.0" ];
      };
      pkgs = import nixpkgs ({ inherit system; } // pkgs-params);
      pkgs-unstable = import nixpkgs-unstable ({ inherit system; } // pkgs-params);
      pkgs-unstable-vscode = import nixpkgs-unstable-vscode ({ inherit system; } // pkgs-params);

      mkNixosConfig = { hardwareModules, extraModules ? [ ] }:
        let
          baseModules = [
            ./modules/nixos/configuration.nix
          ];
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hardwareModules ++ extraModules;
          specialArgs = { inherit self pkgs-unstable; };
        };

      mkHomeConfig = { username, extraModules ? [ ] }:
        let
          baseModules = [
            nixvim.homeManagerModules.nixvim
          ];
          utils = import ./lib/utils.nix;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit self utils username pkgs-unstable pkgs-unstable-vscode; };
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
              ./modules/hardware/g14.nix
              nixos-hardware.nixosModules.asus-zephyrus-ga401
            ];
            extraModules = [ ./modules/nixos/g14.nix ];
          };
          "g2-nixos" = mkNixosConfig {
            hardwareModules = [
              ./modules/hardware/g2.nix
            ];
            extraModules = [ ./modules/nixos/g2.nix ];
          };
        };

        homeConfigurations = {
          "fjolne@g14-nixos" = mkHomeConfig {
            username = "fjolne";
            extraModules = [ ./modules/home-manager/desktop/g14.nix ];
          };
          "gamer@g14-nixos" = mkHomeConfig {
            username = "gamer";
            extraModules = [ ./modules/home-manager/desktop/g14-gamer.nix ];
          };
          "fjolne@g2-nixos" = mkHomeConfig {
            username = "fjolne";
            extraModules = [ ./modules/home-manager/desktop/g2.nix ];
          };
          "ec2-user@devcontainer" = mkHomeConfig {
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/server/devcontainer.nix ];
          };
          "fjolne@vps" = mkHomeConfig {
            username = "fjolne";
            extraModules = [ ./modules/home-manager/server/vps.nix ];
          };
          "ilaut@vps" = mkHomeConfig {
            username = "ilaut";
            extraModules = [ ./modules/home-manager/server/vps.nix ];
          };
          "ec2-user@vps" = mkHomeConfig {
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/server/vps.ix ];
          };
          "ec2-user@nixos" = mkHomeConfig {
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/server/nixos.nix ];
          };
          "fjolne@nixos" = mkHomeConfig {
            username = "fjolne";
            extraModules = [ ./modules/home-manager/server/nixos.nix ];
          };
          "piglet@nixos" = mkHomeConfig {
            username = "piglet";
            extraModules = [ ./modules/home-manager/server/nixos.nix ];
          };
        };
      };
    });
}
