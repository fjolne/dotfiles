{ self, pkgs, pkgs-unstable, lib, ... }:

{
  imports = [
    ./nix-ld.nix
  ];

  # `nix run nixpkgs#hello` will use nixpkgs from this flake
  nix.registry.nixpkgs.flake = self.inputs.nixpkgs;
  # <nixpkgs> will resolve to this flake
  nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [
    # "https://cuda-maintainers.cachix.org"
    # "https://numtide.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    # "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    # "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
  ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = true;
  # Wayland
  services.xserver.displayManager.gdm.wayland = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # for Electron apps

  # === graphics ===
  boot.kernelModules = [ "video" ];
  boot.kernelParams = [ "acpi_backlight=video" "nomodeset" "amdgpu.modeset=0" "module_blacklist=amdgpu" "modprobe.blacklist=amdgpu"];
  hardware.graphics.enable = true;
  # nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime.sync.enable = true;
  hardware.nvidia.prime.offload.enable = false;
  hardware.nvidia.prime.offload.enableOffloadCmd = false;
  # hardware.nvidia.powerManagement.enable = false;
  hardware.nvidia.dynamicBoost.enable = false;
  hardware.nvidia-container-toolkit.enable = true;
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  specialisation = {
    # amd.configuration = {
    #   services.xserver.videoDrivers = lib.mkForce [ "amdgpu" ];
    #   hardware.nvidia-container-toolkit.enable = lib.mkForce false;
    #   imports = [ self.inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable ];
    # };
    # nvidia.configuration = {
    #   # imports = [ nixos-hardware.nixosModules.common-gpu-nvidia ]; # .../prime.nix
    # };
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Don't forget to set a password with ‘passwd’.
  programs.fish.enable = true;
  users.users.fjolne = {
    isNormalUser = true;
    description = "Oleg Martynov";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
    openssh.authorizedKeys = {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyva32b9/JANUGZEgQny/wemAETo4z6wAkF16CLk7fF"
      ];
    };
  };

  environment = {
    variables = {
      # QT_QPA_PLATFORMTHEME = "Adwaita-Dark";
    };
    shells = with pkgs; [ fish ];
    systemPackages = with pkgs; [
      git
      gnumake
      git-crypt
      pinentry
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };
  programs.ssh.startAgent = true;
  services.openssh.enable = false;
  services.tailscale.enable = true;
  services.tailscale.package = pkgs-unstable.tailscale;
  services.tailscale.useRoutingFeatures = "client";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "fjolne" ];
  services.flatpak.enable = true;

  hardware.bluetooth.settings = {
    General = {
      ControllerMode = "bredr";
      "ControllerMode " = "dual";
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  services.envfs.enable = true; # populate /bin and /usr/bin with current binaries for normie scripts

  system.stateVersion = "23.05"; # do not change
}
