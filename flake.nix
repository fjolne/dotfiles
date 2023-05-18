{
  description = "Home Manager configuration of ec2-user";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib.extend
        (final: prev: (import ./lib final) // home-manager.lib);
    in
    {
      legacyPackages =
        let
          systems = [ "x86_64-linux" "aarch64-linux" ];
          mapMerge = xs: f: builtins.foldl' (x: y: x // y) { } (map f xs);
        in
        mapMerge systems (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            ${system}.homeConfigurations = {
              "fjolne@g14-fedora" = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ ./hosts/desktop/fjolne.g14-fedora.nix ];
                extraSpecialArgs = { inherit lib; user = "fjolne"; host = "g14-fedora"; };
              };
              "ec2-user@devcontainer" = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ ./hosts/server/fjolne.devcontainer.nix ];
                extraSpecialArgs = { inherit lib; user = "ec2-user"; host = "devcontainer"; };
              };
            } // mapMerge [ "fjolne" "ec2-user" ] (user: {
              ${user} = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ ./hosts/server/fjolne.host.nix ];
                extraSpecialArgs = { inherit lib; user = user; host = "host"; };
              };
            }) // mapMerge [ "fjolne" "ec2-user" ] (user: {
              "${user}@base" = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ ./hosts/base/common.nix ];
                extraSpecialArgs = { user = user; host = "base"; };
              };
            });
          });
    };
}
