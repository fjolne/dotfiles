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

  services.teeworlds = {
    enable = true;
    openPorts = true;
    name = "fjolne-world";
    extraOptions = [
      "sv_map dm1"
      "sv_gametype dm"
    ];
  };

  services.vscode-server.enable = true;
  services.vscode-server.installPath = "~/.vscode-server-insiders";
}
