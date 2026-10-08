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

-- Open/focus YouTube Music in an app-style window.
o.bind("SUPER + M", "YouTube Music", { focus = "YouTube Music", launch = "google-chrome-stable --app='https://music.youtube.com/?hl=en&persist_hl=1' --app-window-size=480,520" })

-- Toggle the PDF Library hosted inside Omarchy's existing Quickshell process.
o.bind("SUPER + ALT + N", "PDF Library", "omarchy-shell shell toggle natori.pdf-library '{}'")

-- Resize the PDF Library from the keyboard in 80-pixel steps.
local pdfLibraryWindow = "title:^PDF Library$"
o.bind("SUPER + CTRL + SHIFT + LEFT", "Narrow PDF Library", hl.dsp.window.resize({ window = pdfLibraryWindow, x = -80, y = 0, relative = true }))
o.bind("SUPER + CTRL + SHIFT + RIGHT", "Widen PDF Library", hl.dsp.window.resize({ window = pdfLibraryWindow, x = 80, y = 0, relative = true }))
o.bind("SUPER + CTRL + SHIFT + UP", "Shorten PDF Library", hl.dsp.window.resize({ window = pdfLibraryWindow, x = 0, y = -80, relative = true }))
o.bind("SUPER + CTRL + SHIFT + DOWN", "Increase PDF Library height", hl.dsp.window.resize({ window = pdfLibraryWindow, x = 0, y = 80, relative = true }))

-- Resize the Zathura window from the keyboard in 80-pixel steps.
local zathuraWindow = "class:^org\\.pwmt\\.zathura$"
o.bind("SUPER + CTRL + ALT + LEFT", "Narrow Zathura", hl.dsp.window.resize({ window = zathuraWindow, x = -80, y = 0, relative = true }))
o.bind("SUPER + CTRL + ALT + RIGHT", "Widen Zathura", hl.dsp.window.resize({ window = zathuraWindow, x = 80, y = 0, relative = true }))
o.bind("SUPER + CTRL + ALT + UP", "Shorten Zathura", hl.dsp.window.resize({ window = zathuraWindow, x = 0, y = -80, relative = true }))
o.bind("SUPER + CTRL + ALT + DOWN", "Increase Zathura height", hl.dsp.window.resize({ window = zathuraWindow, x = 0, y = 80, relative = true }))
