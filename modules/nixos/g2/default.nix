{ inputs, ... }:

with inputs;
{
  imports = [
    ../minecraft-server.nix
    vscode-server.nixosModules.default
  ];

  networking.hostName = "g2-nixos";
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.vscode-server.enable = true;
}
