#!/usr/bin/env nu

# switch home-manager configuration
def "main switch home" [
    target: string = "."
    --skip-secrets (-s)
] {
  let cmd = $"SKIP_SECRETS=($skip_secrets) nix run home-manager/master -- switch -b bak --flake ($target)"
  bash -c $'"($cmd) (if $skip_secrets { "--impure" })"'
}

# switch NixOS configuration
def "main switch nixos" [
    target: string = "."
] {
  sudo nixos-rebuild --install-bootloader switch --flake $target
}

# hard-reload gpg-agent
def "main switch gpg-agent" [] {
  pkill -f gpg-agent | true
  pkill -f pinentry | true
  systemctl --user restart gpg-agent.socket gpg-agent-extra.socket gpg-agent-ssh.socket
}

def main [ ] {
    help main
}
