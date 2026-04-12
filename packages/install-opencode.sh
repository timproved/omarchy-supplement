#!/bin/bash

set -euo pipefail

if command -v opencode >/dev/null 2>&1; then
  echo "OpenCode already installed"
  exit 0
fi

curl -fsSL https://opencode.ai/install | bash
echo "Installed OpenCode"
