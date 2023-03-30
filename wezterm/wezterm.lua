-- https://wezfurlong.org/wezterm/config/files.html#quick-start
--------------------------------------------------------------------------------
local wezterm = require("wezterm")

--------------------------------------------------------------------------------

local config = {
	-- Meta
	check_for_updates = true,
	automatically_reload_config = true, -- causes errors too quickly
	check_for_updates_interval_seconds = 86400,
	quit_when_all_windows_are_closed = true,
	default_cwd = wezterm.home_dir .. "/Library/Mobile Documents/com~apple~CloudDocs/File Hub",

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,

	-- Font / Size
	font_size = 26,
	font = wezterm.font("JetBrains Mono"), -- bundled by wezterm, and using nerdfont already as fallback https://wezfurlong.org/wezterm/config/fonts
	cell_width = 1.0,
	initial_cols = 90,
	initial_rows = 30,

	-- Appearance
	color_scheme = "AdventureTime",
	window_background_opacity = 0.95,
	macos_window_background_blur = 2,
	bold_brightens_ansi_colors = "BrightAndBold",

	-- Scroll
	enable_scroll_bar = true,
	min_scroll_bar_hright = "2cell",
	scrollback_lines = 4000,

	-- Tabs
	enable_tab_bar = true,
	use_fancy_tab_bar = true,
	show_tabs_in_tab_bar = true,
	show_new_tab_button_in_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	-- Keybindings
	disable_default_key_bindings = false,
	keys = {
		{ key = "q", mods = "CMD", action = wezterm.action.QuitApplication },
		{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab },
		{ key = "k", mods = "CMD", action = wezterm.action.CleaScrollback },

		-- hint mode https://wezfurlong.org/wezterm/quickselect.html
		{ key = "f", mods = "CMD", action = wezterm.action.QuickSelect },
		{ key = "f", mods = "CTRL", action = wezterm.action.QuickSelect },
	},
}

--------------------------------------------------------------------------------

return config
