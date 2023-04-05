-- https://wezfurlong.org/wezterm/config/files.html#quick-start
--------------------------------------------------------------------------------

-- THEME
local darkTheme = "Paraiso Dark"
local lightTheme = "Silk Light (base16)"
local opacity = 0.94

--------------------------------------------------------------------------------
-- UTILS
local wt = require("wezterm")
local act = wt.action
local actFun = wt.action_callback
local os = require("os")
local io = require("io")
local log = wt.log_info

local isAtOffice = wt.hostname():find("mini") ~= nil
local isAtMother = wt.hostname():find("Mother") ~= nil

--------------------------------------------------------------------------------
-- SET WINDOW POSITION ON STARTUP

-- on start, move window to the side ("pseudomaximized")
wt.on("gui-startup", function(cmd)
	local pos = { x = 705, y = 0, w = 3140, h = 2170 }
	if isAtOffice then
		pos = { x = 500, y = 0, w = 2800, h = 1800 }
	elseif isAtMother then
		-- pos = { x = 500, y = 0, w = 2800, h = 1800 }
	end
	local _, _, window = wt.mux.spawn_window(cmd or {})
	window:gui_window():set_position(pos.x, pos.y)
	window:gui_window():set_inner_size(pos.w, pos.h)
end)

--------------------------------------------------------------------------------

---selects the color scheme depending on Dark/Light Mode
---@return string name of the string to set in config.colorscheme
local function autoToggleTheme()
	local currentMode = wt.gui.get_appearance()
	local colorscheme = currentMode:find("Dark") and darkTheme or lightTheme
	return colorscheme
end

---cycle through builtin dark schemes in dark mode, and through light schemes in
---light mode
local function themeCycler(window, _)
	local allSchemes = wt.color.get_builtin_schemes()
	local currentMode = wt.gui.get_appearance()
	local currentScheme = window:effective_config().color_scheme
	local darkSchemes = {}
	local lightSchemes = {}

	for name, scheme in pairs(allSchemes) do
		local bg = wt.color.parse(scheme.background) -- parse into a color object
		local h, s, l, a = bg:hsla() ---@diagnostic disable-line: unused-local
		if l < 0.45 then
			table.insert(darkSchemes, name)
		else
			table.insert(lightSchemes, name)
		end
	end
	local schemesToSearch = currentMode:find("Dark") and darkSchemes or lightSchemes

	for i = 1, #schemesToSearch, 1 do
		if schemesToSearch[i] == currentScheme then
			local overrides = window:get_config_overrides() or {}
			local nextScheme = schemesToSearch[i + 1]
			overrides.color_scheme = nextScheme
			window:set_config_overrides(overrides)

			window:copy_to_clipboard(nextScheme)
			-- for notifications to work correctly, they need to be set to "alert"
			-- in the macOS notification settings
			window:toast_notification("Theme:", nextScheme, nil, 4000)
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
	default_cwd = wt.home_dir .. "/Library/Mobile Documents/com~apple~CloudDocs/File Hub/",

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,
	default_cursor_style = "BlinkingBar", -- mostly overwritten by vi-mode.zsh
	cursor_thickness = "0.07cell",
	cursor_blink_rate = 700,
	cursor_blink_ease_in = "Constant", -- "Constant" = no fading
	cursor_blink_ease_out = "Constant",
	force_reverse_video_cursor = false, -- true = color is reverse, false = color by color scheme

	-- Font
	font_size = 27,
	command_palette_font_size = 29,
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" }, -- disable ligatures
	-- INFO even though symbols and nerd font are bundled with wezterm, some
	-- icons have a sizing issues, therefore explicitly using the Nerd Font here
	font = wt.font("JetBrainsMono Nerd Font", {
		weight = "Medium", -- tad thicker than "Regular"
	}),

	-- Size
	adjust_window_size_when_changing_font_size = false,
	cell_width = 1.0,
	line_height = 1.0,

	-- Appearance
	front_end = "WebGpu", -- better rendering on newer Macs
	audible_bell = "Disabled",
	color_scheme = autoToggleTheme(),
	window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW",
	bold_brightens_ansi_colors = "BrightAndBold",
	window_background_opacity = opacity,
	max_fps = isAtMother and 40 or 60,
	native_macos_fullscreen_mode = false,
	window_padding = {
		left = "0.5cell",
		right = "1.2cell", -- if scrollbar enabled, controls its width, too
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
	show_tabs_in_tab_bar = true, -- can show a status line in the tab bar
	show_new_tab_button_in_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	-- Mouse Bindings
	disable_default_mouse_bindings = false,
	mouse_bindings = {
		-- open link at normal leftclick & auto-copy selection if not a link
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "",
			action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard"),
		},
	},

	-- KEYBINDINGS
	-- Actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
	-- Keynames: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments
	disable_default_key_bindings = true,
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
		{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },

		-- using the mapping from the terminal_keybindings.zsh
		{ key = "z", mods = "CMD", action = act.SendKey { key = "z", mods = "CTRL" } },
		{ key = "b", mods = "CMD", action = act.SendKey { key = "b", mods = "CTRL" } },

		-- scroll-to-prompt, requires shell integration: https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html
		{ key = "k", mods = "CTRL", action = act.ScrollToPrompt(-1) },
		{ key = "j", mods = "CTRL", action = act.ScrollToPrompt(1) },

		{ -- cmd+o -> open link (like f in vimium)
			key = "o",
			mods = "CMD",
			action = act.QuickSelectArgs {
				patterns = { "https?://\\S+" },
				label = "Open URL",
				action = actFun(function(window, pane)
					local url = window:get_selection_text_for_pane(pane)
					wt.open_with(url)
				end),
			},
		},
		{ -- cmd+, -> open this config file
			key = ",",
			mods = "CMD",
			action = actFun(function() wt.open_with(wt.config_file) end),
		},
		{ key = "r", mods = "CMD", action = act.ReloadConfiguration },

		{ -- cmd+l -> open current location in Finder
			key = "l",
			mods = "CMD",
			action = actFun(function(_, pane)
				local cwd = pane:get_current_working_dir()
				wt.open_with(cwd, "Finder")
			end),
		},
		-- Theme Cycler
		{ key = "t", mods = "SHIFT|CTRL|ALT", action = wt.action_callback(themeCycler) },

		--------------------------------------------------------------------------
		-- MODES

		-- Search
		{ key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },

		-- Console / REPL
		{ key = "Escape", mods = "CTRL", action = wt.action.ShowDebugOverlay },

		-- copy mode https://wezfurlong.org/wezterm/copymode.html
		{ key = "c", mods = "CMD|SHIFT", action = act.ActivateCopyMode },

		-- hint mode https://wezfurlong.org/wezterm/quickselect.html
		{ key = "f", mods = "CMD|SHIFT", action = act.QuickSelect },
	},
}
