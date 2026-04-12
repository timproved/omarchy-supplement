#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

HYPR_DIR="$HOME/.config/hypr"
HYPRLAND_CONFIG="$HYPR_DIR/hyprland.conf"
MANAGED_BINDINGS_SOURCE="$SCRIPT_DIR/config/hypr/bindings.conf"
MANAGED_SUPPLEMENT_SOURCE="$SCRIPT_DIR/config/hypr/omarchy-supplement.conf"
MANAGED_TMUX_SOURCE="$SCRIPT_DIR/config/tmux/tmux.conf"
MANAGED_SHELL_SOURCE="$SCRIPT_DIR/config/shell/interactive.sh"
TARGET_BINDINGS="$HYPR_DIR/bindings.conf"
TARGET_SUPPLEMENT="$HYPR_DIR/omarchy-supplement.conf"
TARGET_TMUX="$HOME/.config/tmux/tmux.conf"
TARGET_SHELL_SNIPPET="$HOME/.config/omarchy-supplement/shell/interactive.sh"
PACKAGES_DIR="$SCRIPT_DIR/packages"
SUPPLEMENT_SOURCE_LINE='source = ~/.config/hypr/omarchy-supplement.conf'
BASH_SOURCE_LINE='[[ -f ~/.config/omarchy-supplement/shell/interactive.sh ]] && source ~/.config/omarchy-supplement/shell/interactive.sh'
ZSH_SOURCE_LINE='[[ -f ~/.config/omarchy-supplement/shell/interactive.sh ]] && source ~/.config/omarchy-supplement/shell/interactive.sh'

RUN_CONFIGS=1
RUN_PACKAGES=1

usage() {
  cat <<'EOF'
Usage: ./install.sh [option]

Options:
  --configs-only   Only install and wire up config files
  --packages-only  Only install packages and tools
  --help           Show this help text
EOF
}

backup_suffix() {
  date +%Y%m%d%H%M%S
}

link_managed_file() {
  local source_file=$1
  local target_file=$2
  local target_dir
  local target_real
  local source_real
  local backup_file

  target_dir=$(dirname "$target_file")
  mkdir -p "$target_dir"

  source_real=$(readlink -f "$source_file")

  if [[ -L $target_file ]]; then
    target_real=$(readlink -f "$target_file")

    if [[ $target_real == "$source_real" ]]; then
      echo "Managed link already in place: $target_file"
      return
    fi

    rm "$target_file"
  elif [[ -e $target_file ]]; then
    backup_file="$target_file.pre-omarchy-supplement.$(backup_suffix).bak"
    mv "$target_file" "$backup_file"
    echo "Backed up existing file: $backup_file"
  fi

  ln -s "$source_file" "$target_file"
  echo "Linked $target_file -> $source_file"
}

ensure_hyprland_source() {
  if [[ ! -f $HYPRLAND_CONFIG ]]; then
    echo "Hyprland config not found at $HYPRLAND_CONFIG"
    return 1
  fi

  if grep -Fxq "$SUPPLEMENT_SOURCE_LINE" "$HYPRLAND_CONFIG"; then
    echo "Hyprland already sources omarchy-supplement.conf"
    return
  fi

  printf '\n%s\n' "$SUPPLEMENT_SOURCE_LINE" >> "$HYPRLAND_CONFIG"
  echo "Added supplement source to $HYPRLAND_CONFIG"
}

ensure_source_line() {
  local target_file=$1
  local source_line=$2

  if [[ ! -f $target_file ]]; then
    printf '%s\n' "$source_line" > "$target_file"
    echo "Created $target_file"
    return
  fi

  if grep -Fxq "$source_line" "$target_file"; then
    echo "Source line already present in $target_file"
    return
  fi

  printf '\n%s\n' "$source_line" >> "$target_file"
  echo "Added source line to $target_file"
}

install_packages() {
  local installer
  local -a installers=()

  if [[ ! -d $PACKAGES_DIR ]]; then
    echo "Packages directory not found: $PACKAGES_DIR"
    return 1
  fi

  shopt -s nullglob
  installers=("$PACKAGES_DIR"/install-*.sh)
  shopt -u nullglob

  if (( ${#installers[@]} == 0 )); then
    echo "No package installers found in $PACKAGES_DIR"
    return 0
  fi

  for installer in "${installers[@]}"; do
    echo "Running $(basename "$installer")"
    bash "$installer"
  done
}

install_configs() {
  link_managed_file "$MANAGED_BINDINGS_SOURCE" "$TARGET_BINDINGS"
  link_managed_file "$MANAGED_SUPPLEMENT_SOURCE" "$TARGET_SUPPLEMENT"
  link_managed_file "$MANAGED_TMUX_SOURCE" "$TARGET_TMUX"
  link_managed_file "$MANAGED_SHELL_SOURCE" "$TARGET_SHELL_SNIPPET"
  ensure_hyprland_source
  ensure_source_line "$HOME/.bashrc" "$BASH_SOURCE_LINE"
  ensure_source_line "$HOME/.zshrc" "$ZSH_SOURCE_LINE"

  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi

  if command -v omarchy-restart-tmux >/dev/null 2>&1; then
    omarchy-restart-tmux >/dev/null 2>&1 || true
  elif command -v tmux >/dev/null 2>&1; then
    tmux source-file "$TARGET_TMUX" >/dev/null 2>&1 || true
  fi
}

while (( $# > 0 )); do
  case "$1" in
    --configs-only)
      RUN_CONFIGS=1
      RUN_PACKAGES=0
      ;;
    --packages-only)
      RUN_CONFIGS=0
      RUN_PACKAGES=1
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac

  shift
done

if (( RUN_PACKAGES == 1 )); then
  install_packages
fi

if (( RUN_CONFIGS == 1 )); then
  install_configs
fi

echo "Omarchy supplement install complete"
