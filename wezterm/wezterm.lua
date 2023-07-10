-- THEME SETTINGS

local lightOpacity = 0.93
local darkOpacity = 0.91

local darkTheme = "cyberpunk"
local lightTheme = "Atelier Cave Light (base16)"

-- okay-ish themes
---@diagnostic disable: unused-local
local darkThemes = {
	"Paraiso Dark",
	"Afterglow (Gogh)",
	"Tinacious Design (Dark)",
	"SynthWave (Gogh)",
	"duckbones",
	"MaterialDesignColors",
	"Kanagawa (Gogh)",
	"TokyoNight (Gogh)",
	"ChallengerDeep",
	"cyberpunk",
}
local lightThemes = {
	"OneHalfLight",
	"Google Light (Gogh)",
	"Paraiso (light) (terminal.sexy)",
	"seoulbones_light",
	"BlulocoLight (Gogh)",
	"Edge Light (base16)",
	"Atelierdune (light) (terminal.sexy)",
	"Atelier Lakeside Light (base16)",
	"Cupcake (base16)",
	"Ivory Light (terminal.sexy)",
	"Sakura (base16)",
	"Solar Flare Light (base16)",
	"Atelier Cave Light (base16)",
	"Silk Light (base16)",
}
---@diagnostic enable: unused-local
--------------------------------------------------------------------------------
-- UTILS

local theme = require("theme-utils")
local wt = require("wezterm")
local act = wt.action
local actFun = wt.action_callback

local isAtOffice = (wt.hostname():find("mini") or wt.hostname():find("eduroam")) ~= nil
local isAtMother = wt.hostname():find("Mother") ~= nil

--------------------------------------------------------------------------------
-- SET WINDOW POSITION ON STARTUP

-- on start, move window to the side ("pseudomaximized")
wt.on("gui-startup", function(cmd)
	local pos = { x = 710, y = 0, w = 3135 }
	if isAtOffice then
		pos = { x = 375, y = -100, w = 1675 }
	elseif isAtMother then
		pos = { x = 620, y = 0, w = 2745 }
	end
	local height = 3000 -- automatically truncated to maximum
	local _, _, window = wt.mux.spawn_window(cmd or {})
	window:gui_window():set_position(pos.x, pos.y)
	window:gui_window():set_inner_size(pos.w, height)
end)

--------------------------------------------------------------------------------
-- BETTER PASTE

local function autoQuotePastedUrls(window, pane)
	local pasteCmd = "pbpaste" -- change this if not on macOS
	local success, clipb, stderr = wt.run_child_process { pasteCmd }
	if not success then
		local msg = "pbpaste failed: " .. stderr
		wt.log_info(msg)
		window:toast_notification(msg, nil, 4000)
		return
	end

	if clipb:find("^https?://") then clipb = '"' .. clipb .. '"' end
	pane:paste(clipb)
end

--------------------------------------------------------------------------------
-- KEYBINDINGS
local keybindings = {
	-- Actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
	-- Key-Names: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "q", mods = "CMD", action = act.QuitApplication },
	{ key = "c", mods = "CMD", action = act.CopyTo("ClipboardAndPrimarySelection") },
	{ key = "w", mods = "CMD", action = act.CloseCurrentTab { confirm = false } },
	{ key = "+", mods = "CMD", action = act.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = act.ResetFontSize },
	{ key = "p", mods = "CMD", action = act.ActivateCommandPalette },
	{ key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackAndViewport") },
	{ key = "Enter", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "v", mods = "CMD", action = actFun(autoQuotePastedUrls) },

	-- using the mapping from the terminal_keybindings.zsh
	-- undo
	{ key = "z", mods = "CMD", action = act.SendKey { key = "z", mods = "CTRL" } },
	-- Harpoon (directory cycler)
	{ key = "Enter", mods = "CMD", action = act.SendKey { key = "o", mods = "CTRL" } },

	-- scroll-to-prompt, requires shell integration: https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html
	{ key = "k", mods = "CTRL", action = act.ScrollToPrompt(-1) },
	{ key = "j", mods = "CTRL", action = act.ScrollToPrompt(1) },

	{ -- cmd+u -> open URL (like f in vimium)
		key = "u",
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
	{ -- cmd+o -> copy shell option (e.g. to copy stuff from a man page)
		key = "o",
		mods = "CMD",
		action = act.QuickSelectArgs {
			patterns = {
				"--[\\w=-]+", -- long option
				"-\\w", -- short option
			},
			label = "Copy Shell Option",
		},
	},
	{ -- cmd+, -> open this config file
		key = ",",
		mods = "CMD",
		action = actFun(function() wt.open_with(wt.config_file) end),
	},
	{ -- cmd+l -> open current location in Finder
		key = "l",
		mods = "CMD",
		action = actFun(function(_, pane)
			local cwd = pane:get_current_working_dir()
			wt.open_with(cwd, "Finder")
		end),
	},
	-- Theme Cycler
	{ key = "t", mods = "CMD|ALT", action = actFun(theme.cycle) },

	-- MODES
	-- Search
	{ key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },

	-- Console / REPL
	{ key = "Escape", mods = "CTRL", action = wt.action.ShowDebugOverlay },

	-- copy mode https://wezfurlong.org/wezterm/copymode.html
	{ key = "c", mods = "CMD|SHIFT", action = act.ActivateCopyMode },

	-- hint mode https://wezfurlong.org/wezterm/quickselect.html
	-- can use cmd+c, since wezterm auto-copies mouse selection, freeing up cmd+c
	{ key = "c", mods = "CMD", action = act.QuickSelect },

	-- FIX works with `send_composed_key_when_right_alt_is_pressed = true`
	-- but expects another character, so this mapping fixes it
	{ key = "n", mods = "META", action = act.SendString("~") },
}

--------------------------------------------------------------------------------
-- TAB FORMATTING
-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
wt.on("format-tab-title", function(tab, _, _, _, _, _)
	-- prefers the title that was set via `tab:set_title()` or `wezterm cli
	-- set-tab-title`, but falls back to the title of the active pane in that tab
	local title = tab.tab_title
	if not title or title == "" then title = tab.active_pane.title end
	if title == "zsh" or title == "wezterm" then title = "Terminal" end

	title = "  " .. title .. "  "
	return { { Text = title } }
end)

--------------------------------------------------------------------------------
-- HYPERLINK RULES
local myHyperlinkRules = wt.default_hyperlink_rules()

-- make github links of the form `owner/repo` clickable
table.insert(myHyperlinkRules, {
	regex = [["?(\b[-\w]+)/([-\w.]+)"?]],
	highlight = 0,
	format = "https://github.com/$1/$2",
})

-- links that are probably file paths
table.insert(myHyperlinkRules, {
	regex = [[/\b\S*\b]],
	highlight = 0,
	format = "file://$0",
})

--------------------------------------------------------------------------------
-- SETTINGS

local config = {
	-- Meta
	check_for_updates = false, -- done via homebrew already
	automatically_reload_config = true,

	-- Passwords
	-- INFO `sudo visudo`, and change line `Defaults env_reset` to `Defaults env_reset,pwfeedback`
	-- to see asterisks in general
	detect_password_input = false,

	-- Start/Close
	default_cwd = wt.home_dir .. "/Library/Mobile Documents/com~apple~CloudDocs/File Hub/",
	quit_when_all_windows_are_closed = true,
	window_close_confirmation = "NeverPrompt",

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,
	default_cursor_style = "BlinkingBar", -- mostly overwritten by vi-mode.zsh
	cursor_thickness = "0.07cell",
	cursor_blink_rate = 700,
	cursor_blink_ease_in = "Constant", -- Constant = no fading
	cursor_blink_ease_out = "Constant",
	force_reverse_video_cursor = true, -- true = color is reverse, false = color by color scheme

	-- Font
	font_size = isAtMother and 24 or 26,
	command_palette_font_size = 29,
	-- INFO even though symbols and nerd font are bundled with wezterm, some
	-- icons have a sizing issues, therefore explicitly using the Nerd Font here
	font = wt.font("JetBrainsMono Nerd Font", {
		weight = "Medium", -- tad thicker
	}),
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" }, -- disable ligatures

	-- Size
	adjust_window_size_when_changing_font_size = false,
	cell_width = 1.0,
	line_height = 1.0,

	-- Appearance
	audible_bell = "Disabled",
	color_scheme = theme.autoScheme(darkTheme, lightTheme),
	window_background_opacity = theme.autoOpacity(darkOpacity, lightOpacity),
	bold_brightens_ansi_colors = "BrightAndBold",
	max_fps = isAtMother and 40 or 60,

	-- remove titlebar, but keep macOS traffic lights, enabling menu bar stuff,
	-- especially the "Window" Menu containing window split commands
	-- (used by Hammerspoon)
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	native_macos_fullscreen_mode = false,

	-- Scroll & Scrollbar
	enable_scroll_bar = true,
	window_padding = {
		left = "0.5cell",
		right = "1.1cell", -- if scrollbar enabled, "rights" controls scrollbar width
		top = "0.8cell", -- account for macOS traffic lights
		bottom = "0.3cell",
	},
	min_scroll_bar_height = "3cell",
	scrollback_lines = 5000,

	-- Hyperlinks
	hyperlink_rules = myHyperlinkRules,

	-- Tabs
	enable_tab_bar = true,
	tab_max_width = 30,
	use_fancy_tab_bar = false, -- `false` makes the tabs bigger
	show_tabs_in_tab_bar = true, -- can show a status line in the tab bar, too
	show_new_tab_button_in_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	-- Mouse Bindings
	disable_default_mouse_bindings = false,
	mouse_bindings = {
		{ -- open link at normal leftclick & auto-copy selection if not a link
			event = { Up = { streak = 1, button = "Left" } },
			mods = "",
			action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard"),
		},
	},

	-- Keybindings
	disable_default_key_bindings = true,
	keys = keybindings,
	send_composed_key_when_left_alt_is_pressed = true, -- fix @{}~ etc. on German keyboard
	send_composed_key_when_right_alt_is_pressed = true,
}

--------------------------------------------------------------------------------

return config
