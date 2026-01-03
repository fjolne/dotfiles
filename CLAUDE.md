# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS dotfiles repository using Nix flakes for declarative system and home-manager configurations. It manages multiple machines (desktop and server configurations) with shared and machine-specific modules.

## Essential Commands

### Development Environment
```bash
# Enter development shell with required tools
nix develop

# Format Nix files
nixpkgs-fmt <file.nix>
```

### Home Manager (User Environment)
```bash
# Switch home-manager configuration
just home-switch .#fjolne@g14-nixos
# Or using the full command:
nix run .#home-manager -- switch -b bak --flake .#<username>@<hostname>

# Skip secrets during build (useful for testing)
SKIP_SECRETS=1 just home-switch .#fjolne@vps
```

### NixOS System (Requires sudo)
```bash
# Switch system configuration
just nixos-switch .#g14-nixos
# Or: sudo nixos-rebuild switch --flake .#<hostname>

# Boot to new configuration without switching
just nixos-boot .#g14-nixos
```

### Secrets Management
This repository uses git-crypt for encrypted secrets:
```bash
# Import GPG key (interactive, from stdin)
just gpg-import

# Unlock git-crypt encrypted files
just crypt-unlock

# Hard-reload GPG agent
just gpg-agent-switch
```

## Architecture

### Flake Structure

The flake defines configurations through two main builders:

- **`mkNixosConfig`**: Creates NixOS system configurations
  - Base: `modules/nixos/configuration.nix`
  - Hardware modules from `modules/hardware/` and `nixos-hardware`
  - Machine-specific modules from `modules/nixos/`

- **`mkHomeConfig`**: Creates home-manager configurations
  - Base: `modules/home-manager/base.nix`
  - Desktop configs: `modules/home-manager/desktop/`
  - Server configs: `modules/home-manager/server/`

### Configuration Layering

1. **Base Layer** (`modules/home-manager/base.nix`):
   - Shell environment (fish, tmux, starship)
   - Core CLI tools (ripgrep, fd, jq, neovim)
   - Git configuration
   - Common aliases and environment variables

2. **Desktop Layer** (`modules/home-manager/desktop/common.nix`):
   - Imports base + GNOME + Kitty
   - GUI applications (Chrome, Telegram, Cursor)
   - Desktop-specific SSH keepalive settings

3. **Server Layer** (`modules/home-manager/server/`):
   - Minimal configurations for VPS/EC2/container environments
   - No GUI applications

4. **Machine-Specific Configs**:
   - `g14.nix`, `g2.nix`: Desktop machine specifics
   - `vps.nix`, `devcontainer.nix`: Server environment specifics

### Key Modules

- **`lib/utils.nix`**: Provides `readSecretFile` function that respects `SKIP_SECRETS` env var
- **`packages/`**: Custom package definitions (leafish, bws, tic-80, code-cursor)
- **`modules/nixos/nix-ld.nix`**: Enables nix-ld for binary compatibility

### Configuration Targets

Available homeConfigurations:
- Desktop users: `fjolne@g14-nixos`, `gamer@g14-nixos`, `fjolne@g2-nixos`
- Server users: `fjolne@vps`, `ec2-user@devcontainer`, `fjolne@nixos`, etc.

Available nixosConfigurations:
- `g14-nixos`: ASUS Zephyrus G14 laptop
- `g2-nixos`: G2 machine

## Special Considerations

### Secrets
- Git-crypt encrypted files require GPG key import and unlock before building
- Use `SKIP_SECRETS=1` environment variable to skip secret file reads during development
- GPG agent forwarding is configured for remote machines (see TIPS.md)

### Custom Packages
Custom packages in `packages/` are exposed via `self.packages.x86_64-linux.<name>` and used in home-manager configurations.

### Unfree Packages
The flake allows unfree packages and permits specific insecure packages (currently electron-25.9.0).

### GPU Configuration
The NixOS configuration includes complex GPU setup for hybrid graphics (NVIDIA + AMD), with kernel parameters to disable amdgpu and enable NVIDIA.
