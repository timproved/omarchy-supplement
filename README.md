# omarchy-supplement

Repo-managed Omarchy customizations and bootstrap scripts.

## Usage

```bash
./install.sh
./install.sh --configs-only
./install.sh --packages-only
```

## Layout

```text
config/hypr/bindings.conf
config/hypr/omarchy-supplement.conf
config/alacritty/alacritty.toml
config/git/config
config/ghostty/config
config/keyd/default.conf
config/makima/AT Translated Set 2 keyboard.toml
config/omarchy-supplement/bin/screenshot-select.sh
config/shell/interactive.sh
config/tmux/tmux.conf
config/vim/vimrc
config/xdg-terminals.list
install.sh
packages/install-arch-core.sh
packages/install-keyd.sh
packages/install-neovim-config.sh
packages/install-opencode.sh
packages/install-sdkman.sh
packages/install-tmux-tpm.sh
packages/install-uv.sh
packages/lib.sh
```

`install.sh` does three things:

1. Installs your packages and user tools.
2. Symlinks managed config files into `~/.config/`.
3. Ensures `~/.config/hypr/hyprland.conf` sources `~/.config/hypr/omarchy-supplement.conf`.

## Packages

Package and tool installers now live in `packages/install-*.sh` and are run automatically by `./install.sh`.

- Grouping is fine. One script can install one thing or a small set of related things.
- Shared helpers belong in `packages/lib.sh`.
- `./install.sh --packages-only` still only runs package installers.
- `./install.sh --configs-only` still only wires configs.

Example:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/lib.sh"

install_arch_packages neovim fzf ripgrep
```

Save that as something like `packages/install-dev-tools.sh`, then run `./install.sh --packages-only`.
