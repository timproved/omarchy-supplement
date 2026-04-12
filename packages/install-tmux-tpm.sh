#!/bin/bash

set -euo pipefail

tmux_plugin_dir="$HOME/.config/tmux/plugins/tpm"

if [[ -d $tmux_plugin_dir ]]; then
  echo "TPM already installed"
  exit 0
fi

mkdir -p "$(dirname "$tmux_plugin_dir")"
git clone https://github.com/tmux-plugins/tpm "$tmux_plugin_dir"
echo "Installed TPM"
