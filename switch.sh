#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. ~/.nix-profile/etc/profile.d/nix.sh
nix run home-manager/master -- switch -b bak --flake "$SCRIPT_DIR${1:+#$1}" ${EXTRA_ARGS:-}
