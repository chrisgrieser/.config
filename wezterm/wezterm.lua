-- https://wezfurlong.org/wezterm/config/files.html#quick-start
--------------------------------------------------------------------------------
-- UTILS
local wezterm = require("wezterm")
local act = wezterm.action
local actFun = wezterm.action_callback
-- local os = require("os")
-- local io = require("io")

local log = wezterm.log_info

local isAtOffice = wezterm.hostname():find("mini")
local isAtMother = wezterm.hostname():find("Mother")


--------------------------------------------------------------------------------
-- SET WINDOW POSITION ON STARTUP
local windowPos = {
	x = 705, -- true pixel
	y = 0,
	w = 97, -- cells
	h = 30,
}

-- on start, move window to the side ("pseudomaximized")
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():set_position(windowPos.x, windowPos.y)
end)

--------------------------------------------------------------------------------
-- THEME

local darkTheme = "Ivory Dark (terminal.sexy)"
local lightTheme = "Ivory Light (terminal.sexy)"

---selects the color scheme depending on Dark/Light Mode
---@return string name of the string to set in config.colorscheme
local function autoToggleTheme()
	local currentMode = wezterm.gui.get_appearance()
	local colorscheme = currentMode:find("Dark") and darkTheme or lightTheme
	return colorscheme
end

local function themeCycler(window, _)
	local overrides = window:get_config_overrides() or {}
	local allSchemes = wezterm.color.get_builtin_schemes()
	local currentScheme = window:effective_config().color_scheme
	local found = false

	for scheme, _ in pairs(allSchemes) do -- find the first matching key, then on next iteration set that theme
		if scheme == currentScheme then
			found = true
		elseif found then
			overrides.color_scheme = scheme
			window:set_config_overrides(overrides)
			log("Switched to: " .. scheme)
			return
		end
	end
end

--------------------------------------------------------------------------------
-- MAIN CONFIG
return {
	-- Meta
	check_for_updates = true,
	automatically_reload_config = true, -- causes errors too quickly
	detect_password_input = isAtOffice,

	-- Start/Close
	quit_when_all_windows_are_closed = true,
	window_close_confirmation = "NeverPrompt",
	default_cwd = wezterm.home_dir .. "/Library/Mobile Documents/com~apple~CloudDocs/File Hub/",

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,
	cursor_thickness = "0.07cell",
	cursor_blink_rate = 1100,
	force_reverse_video_cursor = false, -- true = color is reverse, false = color by color scheme

	-- Font / Size
	font_size = 27,
	command_palette_font_size = 29,
	font = wezterm.font("JetBrains Mono"), -- bundled by wezterm, using nerdfont as fallback https://wezfurlong.org/wezterm/config/fonts
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" }, -- disable ligatures
	cell_width = 1.0,
	line_height = 1.0,
	initial_cols = windowPos.w,
	initial_rows = windowPos.h,

	-- Appearance
	color_scheme = autoToggleTheme(),
	window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW",
	bold_brightens_ansi_colors = "BrightAndBold",
	window_background_opacity = 0.95,
	macos_window_background_blur = 2,
	max_fps = isAtMother and 40 or 60,
	native_macos_fullscreen_mode = false,
	window_padding = {
		left = "0.5cell",
		right = "1.3cell", -- if scrollbar enabled, controls its width, too
		top = "0.2cell",
		bottom = "0.4cell",
	},

	-- Scroll
	enable_scroll_bar = true,
	min_scroll_bar_height = "3cell",
	scrollback_lines = 4000,

	-- Tabs
	enable_tab_bar = true,
	tab_max_width = 40,
	use_fancy_tab_bar = false, -- `false` makes the tabs bigger
	show_tabs_in_tab_bar = true,
	show_new_tab_button_in_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	mouse_bindings = {
		-- open link at normal leftclick
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "",
			action = act.OpenLinkAtMouseCursor,
		},
	},

	-- KEYBINDINGS
	-- Actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
	-- Keynames: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments
	disable_default_key_bindings = false,
	keys = {
		{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "q", mods = "CMD", action = act.QuitApplication },
		{ key = "c", mods = "CMD", action = act.CopyTo("ClipboardAndPrimarySelection") },
		{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
		{ key = "w", mods = "CMD", action = act.CloseCurrentTab { confirm = false } },
		{ key = "+", mods = "CMD", action = act.IncreaseFontSize },
		{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
		{ key = "0", mods = "CMD", action = act.ResetFontSize },

		{ key = "p", mods = "CMD", action = act.ActivateCommandPalette },
		{ key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackAndViewport") },
		{ key = "PageDown", mods = "", action = act.ScrollByPage(0.8) },
		{ key = "PageUp", mods = "", action = act.ScrollByPage(-0.8) },
		{ key = "Enter", mods = "SHIFT", action = act.ActivateTabRelative(1) },

		-- using the mapping from the terminal_keybindings.zsh
		{ key = "z", mods = "CMD", action = act.SendKey { key = "z", mods = "CTRL" } },
		{ key = "b", mods = "CMD", action = act.SendKey { key = "b", mods = "CTRL" } },

		-- scroll-to-prompt - not working yet
		-- { key = "K", mods = "CTRL", action = act.ScrollToPrompt(-1) },
		-- { key = "J", mods = "CTRL", action = act.ScrollToPrompt(1) },

		{ -- cmd+, -> open this config file
			key = ",",
			mods = "CMD",
			action = actFun(function() wezterm.open_with(wezterm.config_file) end),
		},
		{ -- cmd+l -> open current location in Finder
			key = "l",
			mods = "CMD",
			action = actFun(function(_, pane)
				local cwd = pane:get_current_working_dir()
				wezterm.open_with(cwd, "Finder")
			end),
		},
		{ -- Theme Cycler
			key = "t",
			mods = "SHIFT|CTRL|ALT",
			action = actFun(themeCycler),
		},

		--------------------------------------------------------------------------
		-- MODES

		-- Search
		{ key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },

		-- Console / REPL
		{ key = "Escape", mods = "CTRL", action = wezterm.action.ShowDebugOverlay },

		-- copy mode https://wezfurlong.org/wezterm/copymode.html
		{ key = "c", mods = "CMD|SHIFT", action = act.ActivateCopyMode },

		-- hint mode https://wezfurlong.org/wezterm/quickselect.html
		{ key = "f", mods = "CMD|SHIFT", action = act.QuickSelect },
	},
}
