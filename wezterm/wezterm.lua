-- https://wezfurlong.org/wezterm/config/files.html#quick-start
--------------------------------------------------------------------------------
local wezterm = require("wezterm")

--------------------------------------------------------------------------------

local config = {
	-- Meta
	check_for_updates = true,
	automatically_reload_config = false, -- causes errors too quickly
	check_for_updates_interval_seconds = 86400,
	quit_when_all_windows_are_closed = true,

	-- Font
	font_size = 26,
	font = wezterm.font("JetBrains Mono"), -- bundled by wezterm, and using nerdfont already as fallback https://wezfurlong.org/wezterm/config/fonts

	-- Appearance
	color_scheme = "AdventureTime",
	enable_scroll_bar = true,
	window_background_opacity = 0.95,

	-- Tabs
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,

	-- Keybindings
	disable_default_key_bindings = false,
	keys = {
		{ key = "q", mods = "CMD", action = wezterm.action.QuitApplication },
	},
}

--------------------------------------------------------------------------------

return config
