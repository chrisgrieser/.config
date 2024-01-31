-- THEME SETTINGS

-- INFO the first theme in the list is used
-- rest are themes I already tried and also like
local darkThemes = {
	"Kanagawa (Gogh)",
	"MaterialDesignColors",
	"ChallengerDeep",
	"cyberpunk",
	"Afterglow (Gogh)",
	"duckbones",
	"Tinacious Design (Dark)",
}
local lightThemes = {
	"Silk Light (base16)",
	"Atelier Lakeside Light (base16)",
	"Ivory Light (terminal.sexy)",
	"Paraiso (light) (terminal.sexy)",
	"seoulbones_light",
	"Solar Flare Light (base16)",
}

local lightOpacity = 0.94
local darkOpacity = 0.91

--------------------------------------------------------------------------------
-- BASE

local keymaps = require("wezterm-keymaps")
local theme = require("theme-utils")
local wt = require("wezterm")
local act = wt.action

local host = wt.hostname()
local isAtOffice = host:find("mini") or host:find("eduroam") or host:find("fak1")
local isAtMother = host:find("Mother")
local isAtHome = host:find("iMac")

local fontSize
local cellWidth
if isAtHome then
	fontSize = 28
	cellWidth = 1
elseif isAtMother then
	fontSize = 26
	cellWidth = 0.9
elseif isAtOffice then
	fontSize = 29
	cellWidth = 0.9
end

--------------------------------------------------------------------------------
-- SET WINDOW POSITION ON STARTUP

wt.on("gui-startup", function(cmd)
	-- on start, move window to the side ("pseudomaximized")
	local pos = { x = 708, y = 0, w = 3135 }
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
-- TAB & WINDOW TITLE

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
wt.on("format-tab-title", function(tab)
	-- prefers the title that was set via `tab:set_title()` or `wezterm cli
	-- set-tab-title`
	local title = tab.tab_title
	if not title or title == "" then title = tab.active_pane.title end

	local icon
	if title == "zsh" or title == "wezterm" then
		local pwdBasefolder = tab.active_pane.current_working_dir.file_path:gsub("^.*/(.*)/$", "%1")
		title = pwdBasefolder
		icon = "  "
	elseif title:find("^docs") then
		icon = "  "
	else
		icon = "  "
	end

	return " " .. icon .. title .. " "
end)

--------------------------------------------------------------------------------
-- SETTINGS

return {
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
		harfbuzz_features = { "calt=0", "clig=0", "liga=0" }, -- disable ligatures
	},
	cell_width = cellWidth, -- effectively like letter-spacing
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
		right = "1.1cell", -- if scrollbar enabled, "right" controls scrollbar width
		top = "0.8cell", -- extra height to account for macOS traffic lights
		bottom = "0.3cell",
	},
	min_scroll_bar_height = "3cell",
	scrollback_lines = 5000,

	-- Tabs
	enable_tab_bar = true,
	tab_max_width = 45, -- I have few tabs, therefore enough space for more width
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
	keys = keymaps.keys,
	key_tables = { copy_mode = keymaps.copymodeKeys },
	disable_default_key_bindings = true,
	send_composed_key_when_left_alt_is_pressed = true, -- fix @{}~ etc. on German keyboard
	send_composed_key_when_right_alt_is_pressed = true,
	use_dead_keys = false, -- do not expect another key after `^~`
}
