#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

HYPR_DIR="$HOME/.config/hypr"
HYPRLAND_CONFIG="$HYPR_DIR/hyprland.conf"
MANAGED_APPLICATIONS_DIR="$SCRIPT_DIR/config/applications"
MANAGED_BINDINGS_SOURCE="$SCRIPT_DIR/config/hypr/bindings.conf"
MANAGED_HYPR_AUTOSTART_SOURCE="$SCRIPT_DIR/config/hypr/autostart.conf"
MANAGED_SUPPLEMENT_SOURCE="$SCRIPT_DIR/config/hypr/omarchy-supplement.conf"
MANAGED_ALACRITTY_SOURCE="$SCRIPT_DIR/config/alacritty/alacritty.toml"
MANAGED_GIT_SOURCE="$SCRIPT_DIR/config/git/config"
MANAGED_GHOSTTY_SOURCE="$SCRIPT_DIR/config/ghostty/config"
MANAGED_MAKIMA_SOURCE="$SCRIPT_DIR/config/makima/AT Translated Set 2 keyboard.toml"
MANAGED_STARSHIP_TEMPLATE_SOURCE="$SCRIPT_DIR/config/omarchy/themed/starship.toml.tpl"
MANAGED_TMUX_SOURCE="$SCRIPT_DIR/config/tmux/tmux.conf"
MANAGED_SHELL_SOURCE="$SCRIPT_DIR/config/shell/interactive.sh"
MANAGED_UNWANTED_WEBAPPS_SOURCE="$SCRIPT_DIR/config/omarchy-supplement/bin/remove-unwanted-webapps.sh"
MANAGED_SCREENSHOT_SOURCE="$SCRIPT_DIR/config/omarchy-supplement/bin/screenshot-select.sh"
MANAGED_CITRIX_XDG_SOURCE="$SCRIPT_DIR/config/omarchy-supplement/bin/set-citrix-xdg-defaults.sh"
MANAGED_VIM_SOURCE="$SCRIPT_DIR/config/vim/vimrc"
MANAGED_WIREPLUMBER_AVRCP_SOURCE="$SCRIPT_DIR/config/wireplumber/wireplumber.conf.d/51-bluez-avrcp.conf"
MANAGED_XDG_TERMINALS_SOURCE="$SCRIPT_DIR/config/xdg-terminals.list"
TARGET_BINDINGS="$HYPR_DIR/bindings.conf"
TARGET_HYPR_AUTOSTART="$HYPR_DIR/autostart.conf"
TARGET_APPLICATIONS_DIR="$HOME/.local/share/applications"
TARGET_SUPPLEMENT="$HYPR_DIR/omarchy-supplement.conf"
TARGET_ALACRITTY="$HOME/.config/alacritty/alacritty.toml"
TARGET_GIT="$HOME/.config/git/config"
TARGET_GHOSTTY="$HOME/.config/ghostty/config"
TARGET_MAKIMA="$HOME/.config/makima/AT Translated Set 2 keyboard.toml"
TARGET_STARSHIP_TEMPLATE="$HOME/.config/omarchy/themed/starship.toml.tpl"
TARGET_STARSHIP="$HOME/.config/starship.toml"
TARGET_TMUX="$HOME/.config/tmux/tmux.conf"
TARGET_SHELL_SNIPPET="$HOME/.config/omarchy-supplement/shell/interactive.sh"
TARGET_UNWANTED_WEBAPPS_SCRIPT="$HOME/.config/omarchy-supplement/bin/remove-unwanted-webapps.sh"
TARGET_SCREENSHOT_SCRIPT="$HOME/.config/omarchy-supplement/bin/screenshot-select.sh"
TARGET_CITRIX_XDG_SCRIPT="$HOME/.config/omarchy-supplement/bin/set-citrix-xdg-defaults.sh"
TARGET_OLD_ICA_XDG_SCRIPT="$HOME/.config/omarchy-supplement/bin/set-ica-xdg-default.sh"
TARGET_VIMRC="$HOME/.vimrc"
TARGET_WIREPLUMBER_AVRCP="$HOME/.config/wireplumber/wireplumber.conf.d/51-bluez-avrcp.conf"
TARGET_XDG_TERMINALS="$HOME/.config/xdg-terminals.list"
CURRENT_THEME_DIR="$HOME/.config/omarchy/current/theme"
CURRENT_THEME_COLORS="$CURRENT_THEME_DIR/colors.toml"
CURRENT_THEME_STARSHIP="$CURRENT_THEME_DIR/starship.toml"
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

hex_to_rgb() {
  local hex="${1#\#}"
  printf "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
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

link_managed_application() {
  local desktop_id=$1

  link_managed_file "$MANAGED_APPLICATIONS_DIR/$desktop_id" "$TARGET_APPLICATIONS_DIR/$desktop_id"
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

render_omarchy_template() {
  local colors_file=$1
  local template_file=$2
  local output_file=$3
  local output_dir
  local sed_script
  local key
  local value
  local rgb

  if [[ ! -f $colors_file || ! -f $template_file ]]; then
    return
  fi

  output_dir=$(dirname "$output_file")
  mkdir -p "$output_dir"
  sed_script=$(mktemp)

  while IFS='=' read -r key value; do
    key="${key//[\"\' ]/}"
    [[ $key && $key != \#* ]] || continue
    value="${value#*[\"\']}"
    value="${value%%[\"\']*}"

    printf 's|{{ %s }}|%s|g\n' "$key" "$value" >> "$sed_script"
    printf 's|{{ %s_strip }}|%s|g\n' "$key" "${value#\#}" >> "$sed_script"

    if [[ $value == \#* ]]; then
      rgb=$(hex_to_rgb "$value")
      printf 's|{{ %s_rgb }}|%s|g\n' "$key" "$rgb" >> "$sed_script"
    fi
  done < "$colors_file"

  sed -f "$sed_script" "$template_file" > "$output_file"
  rm "$sed_script"
  echo "Rendered themed file: $output_file"
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
  link_managed_file "$MANAGED_HYPR_AUTOSTART_SOURCE" "$TARGET_HYPR_AUTOSTART"
  link_managed_application "me.kavishdevar.librepods.desktop"
  link_managed_application "new_store.desktop"
  link_managed_application "receiver.desktop"
  link_managed_application "receiver_fido2.desktop"
  link_managed_application "fido2_llt.desktop"
  link_managed_application "citrixapp.desktop"
  link_managed_application "ctxaadsso.desktop"
  link_managed_file "$MANAGED_SUPPLEMENT_SOURCE" "$TARGET_SUPPLEMENT"
  link_managed_file "$MANAGED_ALACRITTY_SOURCE" "$TARGET_ALACRITTY"
  link_managed_file "$MANAGED_GIT_SOURCE" "$TARGET_GIT"
  link_managed_file "$MANAGED_GHOSTTY_SOURCE" "$TARGET_GHOSTTY"
  if [[ -e $MANAGED_MAKIMA_SOURCE ]]; then
    link_managed_file "$MANAGED_MAKIMA_SOURCE" "$TARGET_MAKIMA"
  fi
  link_managed_file "$MANAGED_STARSHIP_TEMPLATE_SOURCE" "$TARGET_STARSHIP_TEMPLATE"
  render_omarchy_template "$CURRENT_THEME_COLORS" "$TARGET_STARSHIP_TEMPLATE" "$CURRENT_THEME_STARSHIP"
  link_managed_file "$CURRENT_THEME_STARSHIP" "$TARGET_STARSHIP"
  link_managed_file "$MANAGED_TMUX_SOURCE" "$TARGET_TMUX"
  link_managed_file "$MANAGED_SHELL_SOURCE" "$TARGET_SHELL_SNIPPET"
  link_managed_file "$MANAGED_UNWANTED_WEBAPPS_SOURCE" "$TARGET_UNWANTED_WEBAPPS_SCRIPT"
  link_managed_file "$MANAGED_SCREENSHOT_SOURCE" "$TARGET_SCREENSHOT_SCRIPT"
  if [[ -L $TARGET_OLD_ICA_XDG_SCRIPT ]]; then
    rm "$TARGET_OLD_ICA_XDG_SCRIPT"
    echo "Removed obsolete managed link: $TARGET_OLD_ICA_XDG_SCRIPT"
  fi
  link_managed_file "$MANAGED_CITRIX_XDG_SOURCE" "$TARGET_CITRIX_XDG_SCRIPT"
  link_managed_file "$MANAGED_VIM_SOURCE" "$TARGET_VIMRC"
  link_managed_file "$MANAGED_WIREPLUMBER_AVRCP_SOURCE" "$TARGET_WIREPLUMBER_AVRCP"
  link_managed_file "$MANAGED_XDG_TERMINALS_SOURCE" "$TARGET_XDG_TERMINALS"
  bash "$TARGET_UNWANTED_WEBAPPS_SCRIPT"
  bash "$TARGET_CITRIX_XDG_SCRIPT"
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

  if command -v omarchy-restart-terminal >/dev/null 2>&1; then
    omarchy-restart-terminal >/dev/null 2>&1 || true
  fi

  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user restart wireplumber >/dev/null 2>&1 || true
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
