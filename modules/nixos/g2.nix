{ self, lib, ... }:

with self.inputs;
{
  imports = [
    ./minecraft-server.nix
  ];

  services.xserver.videoDrivers = lib.mkForce [ ];
  hardware.nvidia.prime.sync.enable = lib.mkForce false;
  virtualisation.docker.enableNvidia = lib.mkForce false; # for torch+cuda

  networking.hostName = "g2-nixos";
  services.openssh = {
    enable = lib.mkForce true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  boot.supportedFilesystems = [ "ntfs" ];
}
