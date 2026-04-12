#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck source=packages/lib.sh
source "$SCRIPT_DIR/lib.sh"

install_arch_packages bitwarden bun ghostty tmux zsh
