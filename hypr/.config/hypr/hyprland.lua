-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/
--
-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting
-- your ~/.config/hypr files.
require("hypr.monitors")
-- The LG HDR WFHD's native mode is 2560x1080; preferred selects 1920x1080.
hl.monitor({ output = "DP-2", mode = "2560x1080@75", position = "auto", scale = 1 })
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Use a US layout only on the connected Lofree Flow84 keyboard.
hl.device({ name = "flow84@lofree", kb_layout = "us" })

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- YouTube Music window geometry.
o.window("^chrome-music[.]youtube[.]com__-Default$", { tile = true, pseudo = true })

-- Keep the library and reader side by side, and let both windows be resized.
o.window({ class = "^(org\\.quickshell|quickshell)$", title = "^PDF Library$" }, {
  float = true,
  size = { 780, 620 },
  move = { "20", "(monitor_h-window_h)/2" }
})

o.window("^org\\.pwmt\\.zathura$", {
  float = true,
  size = { 600, 700 },
  move = { "(monitor_w-window_w-20)", "(monitor_h-window_h)/2-20" }
})

require("hypr.floating-mode")
