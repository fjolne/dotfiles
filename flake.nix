{
  description = "nix system configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    nvim-conform.url = "github:stevearc/conform.nvim/v5.2.1";
    nvim-conform.flake = false;
    nvim-plenary.url = "github:nvim-lua/plenary.nvim/v0.1.4";
    nvim-plenary.flake = false;
    nvim-telescope.url = "github:nvim-telescope/telescope.nvim/0.1.5";
    nvim-telescope.flake = false;
    nvim-treesitter.url = "github:nvim-treesitter/nvim-treesitter/v0.9.1";
    nvim-treesitter.flake = false;
    vim-copilot.url = "github:github/copilot.vim/v1.11.1";
    vim-copilot.flake = false;
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
      mkNixosConfig = { system, unstableOverlay, hardwareModules, extraModules ? [ ] }:
        let
          baseModules = [
            home-manager.nixosModules.home-manager
            ./modules/nixos/configuration.nix
          ];
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hardwareModules ++ extraModules;
          specialArgs = { inherit self inputs nixpkgs unstableOverlay; };
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
          config.permittedInsecurePackages = [
            "electron-25.9.0"
          ];
        };
      };
      vimOverlay = import ./modules/home-manager/vim-plugins.nix { inherit inputs; };
      pkgs = ((nixpkgs.legacyPackages.${system}.extend unstableOverlay).extend vimOverlay)
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
            inherit system unstableOverlay;
            hardwareModules = [
              ./modules/hardware/g14.nix
              nixos-hardware.nixosModules.asus-zephyrus-ga401
            ];
            extraModules = [ ./modules/nixos/g14.nix ];
          };
          "g2-nixos" = mkNixosConfig {
            inherit system;
            hardwareModules = [
              ./modules/hardware/g2.nix
            ];
            extraModules = [ ./modules/nixos/g2.nix ];
          };
        };

        homeConfigurations = {
          "fjolne@g14-nixos" = mkHomeConfig {
            inherit pkgs;
            username = "fjolne";
            extraModules = [ ./modules/home-manager/desktop/g14.nix ];
          };
          "gamer@g14-nixos" = mkHomeConfig {
            inherit pkgs;
            username = "gamer";
            extraModules = [ ./modules/home-manager/desktop/g14-gamer.nix ];
          };
          "fjolne@g2-nixos" = mkHomeConfig {
            inherit pkgs;
            username = "fjolne";
            extraModules = [ ./modules/home-manager/desktop/g2.nix ];
          };
          "ec2-user@devcontainer" = mkHomeConfig {
            inherit pkgs;
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/server/devcontainer.nix ];
          };
          "fjolne@vps" = mkHomeConfig {
            inherit pkgs;
            username = "fjolne";
            extraModules = [ ./modules/home-manager/server/vps.nix ];
          };
          "ilaut@vps" = mkHomeConfig {
            inherit pkgs;
            username = "ilaut";
            extraModules = [ ./modules/home-manager/server/vps.nix ];
          };
          "ec2-user@vps" = mkHomeConfig {
            inherit pkgs;
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/server/vps.nix ];
          };
          "ec2-user@nixos" = mkHomeConfig {
            inherit pkgs;
            username = "ec2-user";
            extraModules = [ ./modules/home-manager/server/nixos.nix ];
          };
        };
      };
    });
}
