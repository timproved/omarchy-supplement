#!/bin/bash

set -euo pipefail

SCREENSHOT_DIR="$HOME/Pictures/screenshots"

mkdir -p "$SCREENSHOT_DIR"

SELECTION=$(slurp 2>/dev/null)
[[ -n $SELECTION ]] || exit 0

FILEPATH="$SCREENSHOT_DIR/screenshot-$(date +'%d%m%Y-%H%M%S').png"

grim -g "$SELECTION" - | tee "$FILEPATH" | wl-copy --type image/png
notify-send "Screenshot saved and copied" "$FILEPATH" -i "$FILEPATH" -u low -t 2000
