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
      packages =
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
              "fjolne@devcontainer" = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ ./hosts/server/fjolne.devcontainer.nix ];
                extraSpecialArgs = { inherit lib; user = "fjolne"; host = "devcontainer"; };
              };
            } // mapMerge [ "fjolne" "ec2-user" ] (user: {
              ${user} = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ ./hosts/server/fjolne.host.nix ];
                extraSpecialArgs = { inherit lib; user = user; host = "host"; };
              };
            });
          });
    };
}
