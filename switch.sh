#!/usr/bin/env bash

set -euo pipefail

. ~/.nix-profile/etc/profile.d/nix.sh
nix run home-manager/master -- switch -b bak --flake .
