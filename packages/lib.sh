#!/bin/bash

set -euo pipefail

install_arch_packages() {
  if (( $# == 0 )); then
    return 0
  fi

  if command -v omarchy-pkg-add >/dev/null 2>&1; then
    omarchy-pkg-add "$@"
  else
    yay -S --noconfirm --needed "$@"
  fi
}
