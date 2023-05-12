{
  description = "Home Manager configuration of ec2-user";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
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
              extraSpecialArgs = { user = "fjolne"; };
            };
            "fjolne@devcontainer" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [ ./hosts/server/fjolne.devcontainer.nix ];
              extraSpecialArgs = { user = "fjolne"; };
            };
          } // mapMerge [ "fjolne" "ec2-user" ] (user: {
            ${user} = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [ ./hosts/server/fjolne.host.nix ];
              extraSpecialArgs = { user = user; };
            };
          });
        });
  };
}
