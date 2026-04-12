#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(dirname "$SCRIPT_DIR")
KEYD_CONFIG_SOURCE="$REPO_DIR/config/keyd/default.conf"
KEYD_CONFIG_TARGET="/etc/keyd/default.conf"

# shellcheck source=packages/lib.sh
source "$SCRIPT_DIR/lib.sh"

if [[ ! -f $KEYD_CONFIG_SOURCE ]]; then
  echo "Keyd config source not found: $KEYD_CONFIG_SOURCE" >&2
  exit 1
fi

install_arch_packages keyd

sudo mkdir -p /etc/keyd
sudo install -m 0644 "$KEYD_CONFIG_SOURCE" "$KEYD_CONFIG_TARGET"
sudo systemctl enable --now keyd
sudo systemctl restart keyd

echo "Installed keyd and applied $KEYD_CONFIG_TARGET"
