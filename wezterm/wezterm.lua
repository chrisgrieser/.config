-- https://wezfurlong.org/wezterm/config/files.html#quick-start
--------------------------------------------------------------------------------
local wezterm = require("wezterm")
local act = wezterm.action

local isAtOffice = wezterm.hostname():find("mini")
local isAtMother = wezterm.hostname():find("Mother")
local log = wezterm.log_info

--------------------------------------------------------------------------------
log("hostname:", wezterm.hostname())

--------------------------------------------------------------------------------
-- device specific settings
local obscurePassword = isAtOffice 
local fps = isAtMother and 40 or 60


local config = {
	-- Meta
	check_for_updates = true,
	automatically_reload_config = true, -- causes errors too quickly
	check_for_updates_interval_seconds = 86400,
	quit_when_all_windows_are_closed = true,
	window_close_confirmation = "NeverPrompt",

	default_cwd = wezterm.home_dir .. "/Library/Mobile Documents/com~apple~CloudDocs/File Hub",
	detect_password_input = obscurePassword, 

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,
	cursor_thickness = "0.07cell",
	cursor_blink_rate = 900,

	-- Font / Size
	font_size = 26,
	font = wezterm.font("JetBrains Mono"), -- bundled by wezterm, using nerdfont as fallback https://wezfurlong.org/wezterm/config/fonts
	cell_width = 1.0,
	line_height = 1.0,
	initial_cols = 90,
	initial_rows = 30,

	-- Appearance
	color_scheme = "AdventureTime", -- work programmatically w/ color schemes: https://wezfurlong.org/wezterm/config/lua/wezterm/get_builtin_color_schemes.html
	window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW",
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
		{ key = "q", mods = "CMD", action = act.QuitApplication },
		-- { key = "w", mods = "CMD", action = act.CloseCurrentTab },
		-- { key = "f", mods = "CMD", action = act.Search },
		-- { key = "k", mods = "CMD", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },

		-- hint mode https://wezfurlong.org/wezterm/quickselect.html
		-- { key = "f", mods = "CTRL", action = act.QuickSelect },
	},
}

--------------------------------------------------------------------------------

return config
