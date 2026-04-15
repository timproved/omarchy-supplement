#!/bin/bash

set -euo pipefail

SCREENSHOT_DIR="$HOME/Pictures/screenshots"

mkdir -p "$SCREENSHOT_DIR"

SELECTION=$(slurp 2>/dev/null)
[[ -n $SELECTION ]] || exit 0

FILEPATH="$SCREENSHOT_DIR/screenshot-$(date +'%d%m%Y-%H%M%S').png"

grim -g "$SELECTION" "$FILEPATH"
wl-copy <"$FILEPATH"
notify-send "Screenshot saved to clipboard and file" "$FILEPATH" -i "$FILEPATH" -u low -t 2000
