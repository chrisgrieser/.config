--------------------------------------------------------------------------------
-- THEME SETTINGS

-- INFO the first theme in the list is used
-- rest are themes I already tried and also like
local darkThemes = {
	"ChallengerDeep",
	"cyberpunk",
	"Afterglow (Gogh)",
	"duckbones",
	"Tinacious Design (Dark)",
	"Kanagawa (Gogh)",
	"MaterialDesignColors",
}
local lightThemes = {
	"Ivory Light (terminal.sexy)",
	"Cupcake (base16)",
	"Solar Flare Light (base16)",
	"Google Light (Gogh)",
	"Atelier Lakeside Light (base16)",
	"Edge Light (base16)",
	"Silk Light (base16)",
	"seoulbones_light",
	"Paraiso (light) (terminal.sexy)",
	"BlulocoLight (Gogh)",
	"OneHalfLight",
}

local lightOpacity = 0.94
local darkOpacity = 0.91

--------------------------------------------------------------------------------
-- UTILS

local theme = require("theme-utils")
local wt = require("wezterm")
local act = wt.action

local host = wt.hostname()
local isAtOffice = (host:find("mini") or host:find("eduroam") or host:find("fak1")) ~= nil
local isAtMother = host:find("Mother") ~= nil

local fontSize = 28
if isAtMother then fontSize = 26 end
if isAtOffice then fontSize = 30 end

--------------------------------------------------------------------------------
-- SET WINDOW POSITION ON STARTUP

wt.on("gui-startup", function(cmd)
	-- on start, move window to the side ("pseudomaximized")
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
-- KEYBINDINGS

--------------------------------------------------------------------------------
-- TAB TITLE

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
wt.on("format-tab-title", function(tab)
	-- prefers the title that was set via `tab:set_title()` or `wezterm cli
	-- set-tab-title`
	local title = tab.tab_title
	if not title or title == "" then title = tab.active_pane.title end

	local icon
	if title == "zsh" or title == "wezterm" then
		local pwdBasefolder =
			tab.active_pane.current_working_dir:gsub(".*/(.*)/$", "%1"):gsub("%%20", " ")
		title = pwdBasefolder
		icon = "  "
	elseif title:find("^docs") then
		icon = "  "
	else
		icon = "  "
	end

	return " " .. icon .. title .. " "
end)

-- WINDOW TITLE
-- set to pwd basename
-- https://wezfurlong.org/wezterm/config/lua/window-events/format-window-title
wt.on("format-window-title", function(_, pane)
	local pwd = pane.current_working_dir:gsub("^file://[^/]+", ""):gsub("%%20", " ")
	return pwd
end)

--------------------------------------------------------------------------------
-- SETTINGS

local config = {
	-- Meta
	check_for_updates = false, -- done via homebrew already
	automatically_reload_config = true,

	-- Start/Close
	default_cwd = wt.home_dir .. "/Library/Mobile Documents/com~apple~CloudDocs/File Hub/",
	window_close_confirmation = "NeverPrompt",
	quit_when_all_windows_are_closed = true,

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,
	default_cursor_style = "BlinkingBar", -- mostly overwritten by vi-mode.zsh
	cursor_thickness = "0.07cell",
	cursor_blink_rate = 700,
	cursor_blink_ease_in = "Constant", -- Constant = no fading
	cursor_blink_ease_out = "Constant",
	force_reverse_video_cursor = true, -- true = color is reverse, false = color by color scheme

	-- FONT
	-- some nerdfont icons requires a space after them to be properly sized
	font = wt.font {
		family = "Iosevka Term",
		weight = "Medium",
		harfbuzz_features = { "calt=0", "ERLA=1" }, -- disable only `+++` ligatures https://typeof.net/Iosevka/
	},
	font_size = fontSize,
	command_palette_font_size = fontSize,
	char_select_font_size = fontSize, -- emoji picker
	adjust_window_size_when_changing_font_size = false,

	-- Appearance
	audible_bell = "Disabled", -- SystemBeep|Disabled
	visual_bell = { -- briefly flash cursor on visual bell
		fade_in_duration_ms = 500,
		fade_out_duration_ms = 500,
		target = "CursorColor",
	},
	color_scheme = theme.autoScheme(darkThemes[1], lightThemes[1]),
	window_background_opacity = theme.autoOpacity(darkOpacity, lightOpacity),
	bold_brightens_ansi_colors = "BrightAndBold",
	max_fps = isAtMother and 40 or 60,

	-- remove titlebar, but keep macOS traffic lights. Doing so enables
	-- some macOS window bar window-related functionality, like split commands
	-- (used by Hammerspoon)
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	native_macos_fullscreen_mode = false,

	-- Scroll & Scrollbar
	enable_scroll_bar = true,
	window_padding = {
		left = "0.5cell",
		right = "1.1cell", -- if scrollbar enabled, "rights" controls scrollbar width
		top = "0.8cell", -- extra height to account for macOS traffic lights
		bottom = "0.3cell",
	},
	min_scroll_bar_height = "3cell",
	scrollback_lines = 5000,

	-- Tabs
	enable_tab_bar = true,
	tab_max_width = 40, -- I have few tabs, therefore enough space for more width
	use_fancy_tab_bar = false, -- `false` makes the tabs bigger and more in terminal style
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
	keys = require("keybindings"),
	disable_default_key_bindings = true,
	send_composed_key_when_left_alt_is_pressed = true, -- fix @{}~ etc. on German keyboard
	send_composed_key_when_right_alt_is_pressed = true,
}

--------------------------------------------------------------------------------

return config
