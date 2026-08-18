-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- window-switcher (was bound to SUPER+CTRL+RETURN; default is Herdr)
hl.unbind("SUPER + CTRL + RETURN")
o.bind("SUPER + CTRL + RETURN", "Window switcher", "ghostty --title=window-switcher -e ~/.config/hypr/window-switcher.sh")

-- GitHub (was bound to SUPER+SHIFT+G; default is Signal)
hl.unbind("SUPER + SHIFT + G")
o.bind("SUPER + SHIFT + G", "GitHub", { webapp = "https://github.com" })

-- Typora (was bound to SUPER+SHIFT+W; default is Omawrite)
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", o.launch("typora --enable-wayland-ime"))

-- Google Calendar (was bound to SUPER+SHIFT+C; default opens hey.com)
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Calendar", { webapp = "https://calendar.google.com/" })

-- Gmail (was bound to SUPER+SHIFT+E; default opens hey.com)
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://mail.google.com/mail/u/0/" })

-- System monitor (was bound to SUPER+SHIFT+T)
o.bind("SUPER + SHIFT + T", "Activity", "omarchy-launch-tui btop")

-- Emergency JP input (was bound to SUPER+U)
o.bind("SUPER + U", "Emergency JP input", "~/.config/hypr/scripts/omarchy-emergency-input.sh")

-- nvim-cheats (was bound to SUPER+I)
o.bind("SUPER + I", "Nvim cheats", "ghostty --title=nvim-cheats -e ~/.config/hypr/scripts/nvim-cheats.sh")
