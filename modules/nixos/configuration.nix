# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, unstableOverlay, inputs, ... }:

with inputs;
with lib;
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
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

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ unstableOverlay ];

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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [
    "https://cuda-maintainers.cachix.org"
    "https://numtide.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
    pinentryFlavor = "gtk2";
  };
  services.tailscale.enable = true;
  services.tailscale.package = pkgs.unstable.tailscale;
  services.tailscale.useRoutingFeatures = "client";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  imports = [ nixos-hardware.nixosModules.common-gpu-nvidia-disable ];
  # hardware.nvidia.prime.offload.enable = true;
  # hardware.nvidia.powerManagement.enable = true;
  specialisation = {
    nvidia.configuration = {
      system.nixos.tags = [ "nvidiaXXX" ];
      imports = [ nixos-hardware.nixosModules.common-gpu-nvidia ];
      hardware.nvidia.prime.offload.enable = mkForce false;
      hardware.nvidia.powerManagement.enable = mkForce false;
      virtualisation.docker.enableNvidia = true; # for torch+cuda
      environment.sessionVariables.NIXOS_OZONE_WL = "1"; # for Electron apps
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "fjolne" ];


  programs.steam.enable = true;
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
}
