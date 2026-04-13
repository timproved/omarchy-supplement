#!/bin/bash

set -euo pipefail

APP_DIR="$HOME/.local/share/applications"

HANDLERS=(
  "citrix-wfica.desktop|application/x-ica"
  "new_store.desktop|application/vnd.citrix.receiver.configure"
  "receiver.desktop|x-scheme-handler/receiver"
  "receiver_fido2.desktop|x-scheme-handler/citrixauthwebviewdone"
  "fido2_llt.desktop|x-scheme-handler/ctxlinuxamloauth"
  "citrixapp.desktop|x-scheme-handler/citrixapp"
  "ctxaadsso.desktop|x-scheme-handler/ctxaadsso"
)

if ! command -v xdg-mime >/dev/null 2>&1; then
  echo "Skipping ICA XDG default; xdg-mime is unavailable"
  exit 0
fi

if command -v update-desktop-database >/dev/null 2>&1 && [[ -d $APP_DIR ]]; then
  update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

for handler in "${HANDLERS[@]}"; do
  IFS='|' read -r desktop_id mime_type <<< "$handler"

  if [[ ! -f "$APP_DIR/$desktop_id" && ! -f "/usr/share/applications/$desktop_id" ]]; then
    echo "Skipping $mime_type; $desktop_id is not installed"
    continue
  fi

  xdg-mime default "$desktop_id" "$mime_type"

  if [[ $(xdg-mime query default "$mime_type" 2>/dev/null || true) != "$desktop_id" ]]; then
    echo "Failed to set $mime_type default to $desktop_id" >&2
    exit 1
  fi

  echo "Set $mime_type default to $desktop_id"
done
