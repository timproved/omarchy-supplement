#!/bin/bash

set -euo pipefail

if command -v uv >/dev/null 2>&1; then
  echo "uv already installed"
  exit 0
fi

curl -LsSf https://astral.sh/uv/install.sh | sh
echo "Installed uv"
