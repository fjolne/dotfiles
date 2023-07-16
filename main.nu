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

# import private GPG key from stdin
def "main import gpg" [] {
  if not ("~/.gnupg/gpg-agent.conf" | path exists) {
    install -d -m700 -o $env.USER -g $env.USER ~/.gnupg
    $"grab\npinentry-program ((which pinentry).0.path)\n" | save ~/.gnupg/gpg-agent.conf
  }
  cat | GPG_TTY=$"(tty)" gpg --import
}

def main [ ] {
    help main
}
