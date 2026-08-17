#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

HYPR_DIR="$HOME/.config/hypr"
HYPRLAND_CONFIG="$HYPR_DIR/hyprland.lua"
MANAGED_APPLICATIONS_DIR="$SCRIPT_DIR/config/applications"
MANAGED_WEBAPP_ICONS_DIR="$SCRIPT_DIR/config/icons/hicolor"
MANAGED_AGENTS_SOURCE="$SCRIPT_DIR/config/agents/AGENTS.md"
MANAGED_HYPR_SUPPLEMENT_SOURCE="$SCRIPT_DIR/config/hypr/supplement.lua"
MANAGED_ALACRITTY_SOURCE="$SCRIPT_DIR/config/alacritty/alacritty.toml"
MANAGED_GIT_SOURCE="$SCRIPT_DIR/config/git/config"
MANAGED_GHOSTTY_SOURCE="$SCRIPT_DIR/config/ghostty/config"
MANAGED_STARSHIP_TEMPLATE_SOURCE="$SCRIPT_DIR/config/omarchy/themed/starship.toml.tpl"
MANAGED_TMUX_SOURCE="$SCRIPT_DIR/config/tmux/tmux.conf"
MANAGED_SHELL_SOURCE="$SCRIPT_DIR/config/shell/interactive.sh"
MANAGED_UNWANTED_WEBAPPS_SOURCE="$SCRIPT_DIR/config/omarchy-supplement/bin/remove-unwanted-webapps.sh"
MANAGED_CITRIX_XDG_SOURCE="$SCRIPT_DIR/config/omarchy-supplement/bin/set-citrix-xdg-defaults.sh"
MANAGED_SIOYEK_XDG_SOURCE="$SCRIPT_DIR/config/omarchy-supplement/bin/set-sioyek-xdg-defaults.sh"
MANAGED_VIM_SOURCE="$SCRIPT_DIR/config/vim/vimrc"
MANAGED_WIREPLUMBER_BLUEZ_POLICY_SOURCE="$SCRIPT_DIR/config/wireplumber/wireplumber.conf.d/50-bluez-policy.conf"
MANAGED_WIREPLUMBER_AVRCP_SOURCE="$SCRIPT_DIR/config/wireplumber/wireplumber.conf.d/51-bluez-avrcp.conf"
TARGET_APPLICATIONS_DIR="$HOME/.local/share/applications"
TARGET_WEBAPP_ICONS_DIR="$HOME/.local/share/icons/hicolor"
# Resolved by Hyprland's Lua package.path (~/.config/?.lua) as
# require("omarchy-supplement.hypr"). That path has no ?/init.lua pattern, so
# this has to stay a single file rather than a directory.
TARGET_HYPR_SUPPLEMENT="$HOME/.config/omarchy-supplement/hypr.lua"
# One instruction file, linked into each agent CLI's own global path. Claude
# Code reads only ~/.claude/CLAUDE.md at the user level and ignores ~/AGENTS.md
# entirely; Codex and opencode each look somewhere else again.
TARGET_CLAUDE_MEMORY="$HOME/.claude/CLAUDE.md"
TARGET_CODEX_AGENTS="$HOME/.codex/AGENTS.md"
TARGET_OPENCODE_AGENTS="$HOME/.config/opencode/AGENTS.md"
TARGET_ALACRITTY="$HOME/.config/alacritty/alacritty.toml"
TARGET_GIT="$HOME/.config/git/config"
TARGET_GHOSTTY="$HOME/.config/ghostty/config"
TARGET_STARSHIP_TEMPLATE="$HOME/.config/omarchy/themed/starship.toml.tpl"
TARGET_STARSHIP="$HOME/.config/starship.toml"
TARGET_TMUX="$HOME/.config/tmux/tmux.conf"
TARGET_SHELL_SNIPPET="$HOME/.config/omarchy-supplement/shell/interactive.sh"
TARGET_UNWANTED_WEBAPPS_SCRIPT="$HOME/.config/omarchy-supplement/bin/remove-unwanted-webapps.sh"
TARGET_CITRIX_XDG_SCRIPT="$HOME/.config/omarchy-supplement/bin/set-citrix-xdg-defaults.sh"
TARGET_SIOYEK_XDG_SCRIPT="$HOME/.config/omarchy-supplement/bin/set-sioyek-xdg-defaults.sh"
TARGET_OLD_ICA_XDG_SCRIPT="$HOME/.config/omarchy-supplement/bin/set-ica-xdg-default.sh"
TARGET_OLD_SCREENSHOT_SCRIPT="$HOME/.config/omarchy-supplement/bin/screenshot-select.sh"
# Pre-Quattro links: Hyprland read .conf, and this list was repo-managed. The
# terminal list especially has to go, since omarchy-default-terminal writes
# through a symlink and would rewrite the repo file.
TARGET_OLD_HYPR_LINKS=(
  "$HYPR_DIR/bindings.conf"
  "$HYPR_DIR/autostart.conf"
  "$HYPR_DIR/omarchy-supplement.conf"
  "$HOME/.config/xdg-terminals.list"
)
TARGET_VIMRC="$HOME/.vimrc"
TARGET_WIREPLUMBER_BLUEZ_POLICY="$HOME/.config/wireplumber/wireplumber.conf.d/50-bluez-policy.conf"
TARGET_WIREPLUMBER_AVRCP="$HOME/.config/wireplumber/wireplumber.conf.d/51-bluez-avrcp.conf"
# Omarchy renders ~/.config/omarchy/themed/*.tpl into here on every theme set.
CURRENT_THEME_STARSHIP="$HOME/.local/state/omarchy/current/theme/starship.toml"
PACKAGES_DIR="$SCRIPT_DIR/packages"
SUPPLEMENT_SOURCE_LINE='require("omarchy-supplement.hypr")'
TOGGLES_SOURCE_LINE='require("default.hypr.toggles")'
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
    # -m, not -f: an existing link may dangle (e.g. after Omarchy moved a
    # directory out from under it), and -f fails outright on those.
    target_real=$(readlink -m "$target_file")

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

link_managed_webapp_icons() {
  local apps_dir
  local icon_file
  local relative_path

  [[ -d $MANAGED_WEBAPP_ICONS_DIR ]] || return 0

  shopt -s nullglob
  for apps_dir in "$MANAGED_WEBAPP_ICONS_DIR"/*/apps; do
    for icon_file in "$apps_dir"/*.png; do
      [[ -f $icon_file ]] || continue
      relative_path=${icon_file#"$MANAGED_WEBAPP_ICONS_DIR"/}
      link_managed_file "$icon_file" "$TARGET_WEBAPP_ICONS_DIR/$relative_path"
    done
  done
  shopt -u nullglob
}

ensure_hyprland_source() {
  if [[ ! -f $HYPRLAND_CONFIG ]]; then
    echo "Hyprland config not found at $HYPRLAND_CONFIG"
    return 1
  fi

  if grep -Fxq "$SUPPLEMENT_SOURCE_LINE" "$HYPRLAND_CONFIG"; then
    echo "Hyprland already requires the supplement module"
    return
  fi

  # The toggles module carries runtime flags (window gaps, transparency) and has
  # to keep loading last, so insert above it rather than appending.
  sed -i "\|^$TOGGLES_SOURCE_LINE\$|i $SUPPLEMENT_SOURCE_LINE" "$HYPRLAND_CONFIG"

  if ! grep -Fxq "$SUPPLEMENT_SOURCE_LINE" "$HYPRLAND_CONFIG"; then
    printf '\n%s\n' "$SUPPLEMENT_SOURCE_LINE" >> "$HYPRLAND_CONFIG"
  fi

  echo "Added supplement require to $HYPRLAND_CONFIG"
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

remove_obsolete_link() {
  local target_file=$1

  if [[ -L $target_file ]]; then
    rm "$target_file"
    echo "Removed obsolete managed link: $target_file"
  fi
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
  local obsolete_link

  for obsolete_link in "${TARGET_OLD_HYPR_LINKS[@]}"; do
    remove_obsolete_link "$obsolete_link"
  done

  link_managed_file "$MANAGED_HYPR_SUPPLEMENT_SOURCE" "$TARGET_HYPR_SUPPLEMENT"
  link_managed_application "me.kavishdevar.librepods.desktop"
  link_managed_application "sioyek.desktop"
  link_managed_application "outlook-chromium.desktop"
  link_managed_application "teams-chromium.desktop"
  link_managed_application "new_store.desktop"
  link_managed_application "receiver.desktop"
  link_managed_application "receiver_fido2.desktop"
  link_managed_application "fido2_llt.desktop"
  link_managed_application "citrixapp.desktop"
  link_managed_application "ctxaadsso.desktop"
  link_managed_webapp_icons
  link_managed_file "$MANAGED_AGENTS_SOURCE" "$TARGET_CLAUDE_MEMORY"
  link_managed_file "$MANAGED_AGENTS_SOURCE" "$TARGET_CODEX_AGENTS"
  link_managed_file "$MANAGED_AGENTS_SOURCE" "$TARGET_OPENCODE_AGENTS"
  link_managed_file "$MANAGED_ALACRITTY_SOURCE" "$TARGET_ALACRITTY"
  link_managed_file "$MANAGED_GIT_SOURCE" "$TARGET_GIT"
  link_managed_file "$MANAGED_GHOSTTY_SOURCE" "$TARGET_GHOSTTY"
  link_managed_file "$MANAGED_STARSHIP_TEMPLATE_SOURCE" "$TARGET_STARSHIP_TEMPLATE"
  link_managed_file "$CURRENT_THEME_STARSHIP" "$TARGET_STARSHIP"
  link_managed_file "$MANAGED_TMUX_SOURCE" "$TARGET_TMUX"
  link_managed_file "$MANAGED_SHELL_SOURCE" "$TARGET_SHELL_SNIPPET"
  link_managed_file "$MANAGED_UNWANTED_WEBAPPS_SOURCE" "$TARGET_UNWANTED_WEBAPPS_SCRIPT"
  remove_obsolete_link "$TARGET_OLD_ICA_XDG_SCRIPT"
  remove_obsolete_link "$TARGET_OLD_SCREENSHOT_SCRIPT"
  link_managed_file "$MANAGED_CITRIX_XDG_SOURCE" "$TARGET_CITRIX_XDG_SCRIPT"
  link_managed_file "$MANAGED_SIOYEK_XDG_SOURCE" "$TARGET_SIOYEK_XDG_SCRIPT"
  link_managed_file "$MANAGED_VIM_SOURCE" "$TARGET_VIMRC"
  link_managed_file "$MANAGED_WIREPLUMBER_BLUEZ_POLICY_SOURCE" "$TARGET_WIREPLUMBER_BLUEZ_POLICY"
  link_managed_file "$MANAGED_WIREPLUMBER_AVRCP_SOURCE" "$TARGET_WIREPLUMBER_AVRCP"
  if command -v omarchy-default-terminal >/dev/null 2>&1; then
    omarchy-default-terminal ghostty >/dev/null 2>&1 || true
  fi
  bash "$TARGET_UNWANTED_WEBAPPS_SCRIPT"
  bash "$TARGET_SIOYEK_XDG_SCRIPT"
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
