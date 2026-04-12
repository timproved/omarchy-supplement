#!/bin/bash

set -euo pipefail

if [[ -s $HOME/.sdkman/bin/sdkman-init.sh ]]; then
  echo "SDKMAN already installed"
  exit 0
fi

curl -fsSL https://get.sdkman.io | bash
echo "Installed SDKMAN"
