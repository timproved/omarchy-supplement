-- omarchy-supplement: personal Hyprland overrides.
--
-- Loaded from ~/.config/hypr/hyprland.lua after Omarchy's defaults and the
-- stock user modules, but before default.hypr.toggles, so the runtime toggles
-- (SUPER+SHIFT+BACKSPACE gaps, SUPER+BACKSPACE transparency) still win.
--
-- Monitors deliberately live in ~/.config/hypr/monitors.lua instead: they are
-- machine-specific and nwg-displays owns that file.

hl.config({
  general = { gaps_in = 1, gaps_out = 1 },
  input = { accel_profile = "flat" },
})

-- Omarchy tags every window `default-opacity` and dims it; opt everything out.
o.window(".*", { opacity = "1 1" })

-- Keep screenshots in their own directory rather than loose in ~/Pictures.
hl.env("OMARCHY_SCREENSHOT_DIR", (os.getenv("HOME") or "") .. "/Pictures/screenshots")

-- Vim-style focus and window movement.
hl.unbind("SUPER + J") -- was: Toggle window split
hl.unbind("SUPER + K") -- was: Keybindings menu
hl.unbind("SUPER + L") -- was: Toggle workspace layout
o.bind("SUPER + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + SHIFT + H", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.move({ direction = "r" }))
o.bind("SUPER + SHIFT + J", "Move window down", hl.dsp.window.move({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Move window up", hl.dsp.window.move({ direction = "u" }))

o.bind("SUPER + SHIFT + Q", "Close window", hl.dsp.window.close())

-- Menu on SUPER+M instead of SUPER+SPACE.
hl.unbind("SUPER + SPACE")
o.bind("SUPER + M", "Omarchy menu", "omarchy-menu toggle")

hl.unbind("SUPER + S") -- was: Toggle scratchpad
o.bind("SUPER + S", "Screenshot selection", "omarchy-capture-screenshot region")

hl.unbind("SUPER + SHIFT + SLASH") -- was: 1Password, not installed

-- Work apps.
hl.unbind("SUPER + SHIFT + O") -- was: Obsidian
o.bind(
  "SUPER + SHIFT + O",
  "Outlook",
  { launch = "chromium --profile-directory=Default --app=https://outlook.office.com/" }
)
o.bind(
  "SUPER + SHIFT + T",
  "Teams",
  { launch = "chromium --profile-directory=Default --app=https://teams.cloud.microsoft/" }
)
o.bind("SUPER + SHIFT + V", "Bitwarden", { focus = "bitwarden", launch = "bitwarden" })
