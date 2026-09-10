local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.use_ime = true

-- Menlo is available on macOS and matches the spacious, typewriter-like
-- proportions of the reference image.
config.font = wezterm.font_with_fallback({
	"Menlo",
	"Apple Symbols",
})
config.font_size = 14.0
config.line_height = 1.15

-- Leave room for the sparse two-line prompt shown in the reference image.
config.window_padding = {
	left = "2cell",
	right = "2cell",
	top = "1cell",
	bottom = "1cell",
}

config.macos_window_background_blur = 20
config.background = require("background")
config.window_background_opacity = 1.0
config.text_background_opacity = 0.0

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

config.window_frame = {
	inactive_titlebar_bg = "#242833",
	active_titlebar_bg = "#242833",
	inactive_titlebar_fg = "#8f929b",
	active_titlebar_fg = "#e8e5df",
	inactive_titlebar_border_bottom = "#242833",
	active_titlebar_border_bottom = "#242833",
}

config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false

config.colors = {
	foreground = "#F2EFE9",
	background = "#121419",
	cursor_bg = "#F2EFE9",
	cursor_fg = "#121419",
	cursor_border = "#F2EFE9",
	selection_bg = "#756F68",
	selection_fg = "#FFFDF8",
	scrollbar_thumb = "#716E69",
	ansi = {
		"#22242A",
		"#C9857E",
		"#9BB58E",
		"#C5AA7A",
		"#8EA8C5",
		"#AD9AB7",
		"#8FB8B1",
		"#E7E3DC",
	},
	brights = {
		"#5B5D63",
		"#E2A19A",
		"#BDD2AD",
		"#D9C08F",
		"#B0C8E1",
		"#C4B1CE",
		"#B0D3CB",
		"#FFFDF8",
	},
	tab_bar = {
		background = "#242833",
		inactive_tab_edge = "none",
		active_tab = {
			bg_color = "#242833",
			fg_color = "#E8E5DF",
		},
		inactive_tab = {
			bg_color = "#242833",
			fg_color = "#8F929B",
		},
	},
}

config.bold_brightens_ansi_colors = false
config.default_cursor_style = "BlinkingBar"

return config
