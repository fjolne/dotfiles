#!/usr/bin/env nu

# switch home-manager configuration
def "main switch home" [
    target: string = "."
    --skip-secrets (-s)
] {
  let hm_cmd = "nix run .#home-manager --"
  let hm_args = $"switch -b bak --flake ($target) (if $skip_secrets { "--impure" })"
  let flake_args = $"SKIP_SECRETS=($skip_secrets)"
  nu -c $"($flake_args) ($hm_cmd) ($hm_args)"
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

# import private GPG key from stdin
def "main secrets import-gpg" [] {
  if not ("~/.gnupg/gpg-agent.conf" | path exists) {
    install -d -m700 -o $env.USER -g $env.USER ~/.gnupg
    $"grab\npinentry-program ((which pinentry).0.path)\n" | save ~/.gnupg/gpg-agent.conf
  }
  cat | GPG_TTY=$"(tty)" gpg --import
}

# decrypt git-crypt files
def "main secrets unlock" [] {
  git-crypt unlock
  nix store gc
}

def main [ ] {
    help main
}
