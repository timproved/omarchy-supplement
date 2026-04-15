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
config/hypr/autostart.conf
config/hypr/omarchy-supplement.conf
config/applications/citrixapp.desktop
config/applications/ctxaadsso.desktop
config/applications/fido2_llt.desktop
config/applications/me.kavishdevar.librepods.desktop
config/applications/new_store.desktop
config/applications/receiver.desktop
config/applications/receiver_fido2.desktop
config/applications/sioyek.desktop
config/alacritty/alacritty.toml
config/git/config
config/ghostty/config
config/keyd/default.conf
config/makima/AT Translated Set 2 keyboard.toml
config/omarchy/themed/starship.toml.tpl
config/omarchy-supplement/bin/remove-unwanted-webapps.sh
config/omarchy-supplement/bin/set-citrix-xdg-defaults.sh
config/omarchy-supplement/bin/set-sioyek-xdg-defaults.sh
config/omarchy-supplement/bin/screenshot-select.sh
config/shell/interactive.sh
config/tmux/tmux.conf
config/vim/vimrc
config/wireplumber/wireplumber.conf.d/51-bluez-avrcp.conf
config/xdg-terminals.list
install.sh
packages/install-arch-core.sh
packages/install-keyd.sh
packages/install-librepods.sh
packages/install-neovim-config.sh
packages/install-opencode.sh
packages/install-sdkman.sh
packages/install-sioyek.sh
packages/install-tmux-tpm.sh
packages/install-uv.sh
packages/lib.sh
```

`install.sh` does the following:

1. Installs your packages and user tools.
2. Symlinks managed config files into `~/.config/`.
3. Ensures `~/.config/hypr/hyprland.conf` sources `~/.config/hypr/omarchy-supplement.conf`.
4. Reapplies Sioyek as the XDG default for PDF and EPUB files when Sioyek is installed.
5. Reapplies Citrix XDG handlers for `.ica` files and Citrix browser launch URLs when Citrix is installed.

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

## LibrePods

`./install.sh` now manages LibrePods end to end:

1. Installs the `librepods` AUR package via the normal package installer flow.
2. Symlinks a managed `~/.config/hypr/autostart.conf` that launches `librepods --hide` with a per-app Qt style override so it does not inherit Omarchy's global Kvantum setting.
3. Symlinks a managed desktop entry at `~/.local/share/applications/me.kavishdevar.librepods.desktop` so Walker launches LibrePods with the same per-app Qt override.
4. Symlinks `~/.config/wireplumber/wireplumber.conf.d/51-bluez-avrcp.conf` and best-effort restarts WirePlumber so AirPods media controls work.

The `qt.bluetooth.bluez` `CAP_NET_ADMIN` warning is left alone for now; the supplement only fixes the actual launch crash caused by the global Kvantum override.

## Sioyek

`./install.sh` now manages Sioyek end to end:

1. Installs the `sioyek-appimage` AUR package via the normal package installer flow.
2. Symlinks a managed desktop entry at `~/.local/share/applications/sioyek.desktop` that declares both PDF and EPUB MIME support.
3. Reapplies `sioyek.desktop` as the XDG default handler for `application/pdf` and `application/epub+zip`.
