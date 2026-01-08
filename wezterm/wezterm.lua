local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.automatically_reload_config = true
config.font_size = 13.0
config.use_ime = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.show_tabs_in_tab_bar = true

config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}

config.window_background_gradient = {
	colors = { "#000000" },
}

config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false

config.colors = {
	tab_bar = {
		inactive_tab_edge = "none",
	},
}

config.color_scheme = "Solarized Dark - Patched"

return config
