-- https://wezfurlong.org/wezterm/config/files.html#quick-start
--------------------------------------------------------------------------------
local wezterm = require("wezterm")

local isAtOffice = wezterm.hostname()
local log = wezterm.log_info

--------------------------------------------------------------------------------
log("hostname:", hostname)

--------------------------------------------------------------------------------
-- device specific settings
local obscurePassword = hostname:find("mini") -- only hide in office
local fps = hostname:find("mini") -- only hide in office



local config = {
	-- Meta
	check_for_updates = true,
	automatically_reload_config = true, -- causes errors too quickly
	check_for_updates_interval_seconds = 86400,
	quit_when_all_windows_are_closed = true,

	-- TODO change dynamically
	default_cwd = wezterm.home_dir .. "/Library/Mobile Documents/com~apple~CloudDocs/File Hub",
	detect_password_input = obscurePassword, 

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,
	cursor_thickness = "0.2cell",
	cursor_blink_ease_out = "EaseInOut",
	cursor_blink_ease_in = "EaseInOut",
	cursor_blink_rate = 500,

	-- Font / Size
	font_size = 26,
	font = wezterm.font("JetBrains Mono"), -- bundled by wezterm, and using nerdfont already as fallback https://wezfurlong.org/wezterm/config/fonts
	cell_width = 1.0,
	line_height = 1.0,
	initial_cols = 90,
	initial_rows = 30,

	-- Appearance
	-- can work programmatically with color schemes: https://wezfurlong.org/wezterm/config/lua/wezterm/get_builtin_color_schemes.html
	color_scheme = "AdventureTime", 
	window_background_opacity = 0.95,
	macos_window_background_blur = 2,
	native_macos_fullscreen_mode = false,
	max_fps = fps,
	bold_brightens_ansi_colors = "BrightAndBold",
	window_padding = {
		left = 2,
		right = 2, -- if scrollbar enabled, controls its width, too
		top = 1,
		bottom = 1,
	},

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
	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
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
