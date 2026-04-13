#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LIBREPODS_SIGNING_KEY="2D58709F32193AA828ED43D72DBD7F9150AB7E67"
LIBREPODS_GPG_URL="https://github.com/kavishdevar.gpg"

# shellcheck source=packages/lib.sh
source "$SCRIPT_DIR/lib.sh"

ensure_librepods_signing_key() {
  if gpg --list-keys "$LIBREPODS_SIGNING_KEY" >/dev/null 2>&1; then
    return 0
  fi

  curl -fsSL "$LIBREPODS_GPG_URL" | gpg --import -

  gpg --list-keys "$LIBREPODS_SIGNING_KEY" >/dev/null 2>&1
}

ensure_librepods_signing_key
install_aur_packages librepods
