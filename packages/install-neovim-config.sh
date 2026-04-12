#!/usr/bin/env bash

set -euo pipefail

NVIM_CONFIG_DIR="$HOME/.config/nvim"
REPO_URL="git@github.com:timproved/nvim.git"
MIN_NVIM_VERSION="0.12.0"
TARGET_NVIM_VERSION="0.12.1"
TARGET_NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.12.1/nvim-linux-x86_64.tar.gz"
TARGET_NVIM_DIR="/opt/nvim-${TARGET_NVIM_VERSION}"
USER_BIN_DIR="$HOME/.local/bin"
USER_NVIM_LINK="$USER_BIN_DIR/nvim"

version_lt() {
  [[ $(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1) != "$2" ]]
}

current_nvim_version() {
  if ! command -v nvim >/dev/null 2>&1; then
    return 1
  fi

  nvim --version | sed -n '1s/^NVIM v//p'
}

install_nvim_tarball() {
  local archive_path
  local extract_dir
  local extracted_dir

  archive_path=$(mktemp --suffix=.tar.gz)
  extract_dir=$(mktemp -d)
  trap 'rm -f "${archive_path:-}"; rm -rf "${extract_dir:-}"' RETURN

  echo "Installing Neovim v${TARGET_NVIM_VERSION} from GitHub release tarball..."
  curl -fL "$TARGET_NVIM_URL" -o "$archive_path"
  tar -xzf "$archive_path" -C "$extract_dir"

  extracted_dir="$extract_dir/nvim-linux-x86_64"
  if [[ ! -d $extracted_dir ]]; then
    echo "Unexpected tarball layout: $extracted_dir not found" >&2
    exit 1
  fi

  sudo rm -rf "$TARGET_NVIM_DIR"
  sudo mv "$extracted_dir" "$TARGET_NVIM_DIR"

  rm -f "$archive_path"
  rm -rf "$extract_dir"
  trap - RETURN
}

ensure_user_nvim_link() {
  mkdir -p "$USER_BIN_DIR"

  if [[ -e $USER_NVIM_LINK && ! -L $USER_NVIM_LINK ]]; then
    echo "Refusing to replace existing non-symlink at $USER_NVIM_LINK" >&2
    exit 1
  fi

  ln -sfn "$TARGET_NVIM_DIR/bin/nvim" "$USER_NVIM_LINK"
}

ensure_modern_nvim() {
  local installed_version

  if [[ -x "$TARGET_NVIM_DIR/bin/nvim" ]]; then
    echo "Managed Neovim already installed at $TARGET_NVIM_DIR"
    return
  fi

  if installed_version=$(current_nvim_version); then
    if version_lt "$installed_version" "$MIN_NVIM_VERSION"; then
      echo "Neovim v${installed_version} is below v${MIN_NVIM_VERSION}; installing managed v${TARGET_NVIM_VERSION} tarball and leaving the system package in place."

      install_nvim_tarball
      return
    fi

    echo "Neovim v${installed_version} already satisfies the minimum version; installing managed v${TARGET_NVIM_VERSION} tarball for the shell alias."
    install_nvim_tarball
    return
  fi

  echo "Neovim is not installed; installing v${TARGET_NVIM_VERSION}."
  install_nvim_tarball
}

ensure_modern_nvim
ensure_user_nvim_link

if [ -d "$NVIM_CONFIG_DIR" ]; then
  echo "Existing Neovim config found at $NVIM_CONFIG_DIR"
  echo "Removing it..."
  rm -rf "$NVIM_CONFIG_DIR"
fi

echo "Cloning Neovim config from $REPO_URL..."
git clone "$REPO_URL" "$NVIM_CONFIG_DIR"

echo "Done."
