#!/bin/bash

set -euo pipefail

APP_DIR="$HOME/.local/share/applications"
DESKTOP_ID="sioyek.desktop"
MIME_TYPES=(
  "application/pdf"
  "application/epub+zip"
)

if ! command -v xdg-mime >/dev/null 2>&1; then
  echo "Skipping Sioyek XDG defaults; xdg-mime is unavailable"
  exit 0
fi

if command -v update-desktop-database >/dev/null 2>&1 && [[ -d $APP_DIR ]]; then
  update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

if [[ ! -f "$APP_DIR/$DESKTOP_ID" && ! -f "/usr/share/applications/$DESKTOP_ID" ]]; then
  echo "Skipping Sioyek XDG defaults; $DESKTOP_ID is not installed"
  exit 0
fi

for mime_type in "${MIME_TYPES[@]}"; do
  xdg-mime default "$DESKTOP_ID" "$mime_type"

  if [[ $(xdg-mime query default "$mime_type" 2>/dev/null || true) != "$DESKTOP_ID" ]]; then
    echo "Failed to set $mime_type default to $DESKTOP_ID" >&2
    exit 1
  fi

  echo "Set $mime_type default to $DESKTOP_ID"
done
