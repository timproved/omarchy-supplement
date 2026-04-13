#!/bin/bash

set -euo pipefail

DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$DESKTOP_DIR/icons"

remove_packages_if_possible() {
  local packages=()
  local package

  for package in "$@"; do
    if pacman -Q "$package" >/dev/null 2>&1; then
      packages+=("$package")
    fi
  done

  (( ${#packages[@]} > 0 )) || return

  if sudo -n true >/dev/null 2>&1; then
    omarchy-pkg-drop "${packages[@]}"
  else
    printf 'Skipping package removal; run manually with sudo: omarchy-pkg-drop %s\n' "${packages[*]}" >&2
  fi
}

hide_system_launcher() {
  local desktop_id=$1
  local override_file="$DESKTOP_DIR/$desktop_id"

  mkdir -p "$DESKTOP_DIR"
  printf '[Desktop Entry]\nHidden=true\n' > "$override_file"
}

remove_launcher() {
  local desktop_file=$1
  local app_name

  [[ -e $desktop_file ]] || return 0

  app_name=$(basename "${desktop_file%.desktop}")
  rm -f "$desktop_file"
  rm -f "$ICON_DIR/$app_name.png"
  echo "Removed launcher: $app_name"
}

remove_launcher "$DESKTOP_DIR/Basecamp.desktop"
remove_launcher "$DESKTOP_DIR/Figma.desktop"
remove_launcher "$DESKTOP_DIR/Fizzy.desktop"

shopt -s nullglob
for desktop_file in "$DESKTOP_DIR"/Google*.desktop; do
  remove_launcher "$desktop_file"
done
shopt -u nullglob

if command -v omarchy-pkg-drop >/dev/null 2>&1; then
  remove_packages_if_possible 1password-beta 1password-cli
fi

if pacman -Q 1password-beta >/dev/null 2>&1 || pacman -Q 1password-cli >/dev/null 2>&1; then
  hide_system_launcher "1password.desktop"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

if command -v omarchy-restart-walker >/dev/null 2>&1; then
  omarchy-restart-walker >/dev/null 2>&1 || true
fi
