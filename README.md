# Install
Requires only stuff neccessary to install the nix itself from the official installer. For Ubuntu 22.04 that would be:
```shell
sudo apt install curl ca-certificates xz-utils
```
```shell
curl https://raw.githubusercontent.com/fjolne/dotfiles/main/install.sh | CLONE=true bash -x
```

# Tips
- To install without secrets:
```shell
EXTRA_ARGS=--impure SKIP_SECRETS=true ./install.sh
```
- To make nix rebuild the flake after unlock:
```shell
nix-store --gc
```

# GPG Agent Forwarding (for posterity)
Ensure that you local agent is using the `extra` socket and add this to local `.ssh/config`. Replace XXXX with `$(id -u)` on remote and YYYY with `$(id -u)` on local device:
```
Host ...
    ...
    RemoteForward /run/user/XXXX/gnupg/S.gpg-agent /run/user/YYYY/gnupg/S.gpg-agent.extra
```
```shell
echo 'StreamLocalBindUnlink yes' | sudo tee -a /etc/ssh/sshd_config
sudo systemctl reload sshd
logout
...
gpg --import <(curl https://github.com/fjolne.gpg)
```

- https://wiki.gnupg.org/AgentForwarding
- https://gist.github.com/TimJDFletcher/85fafd023c81aabfad57454111c1564d
