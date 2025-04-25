local wt = require("wezterm")
--------------------------------------------------------------------------------

-- CONFIG the first theme in the list is used
local darkThemes = {
	"cyberpunk",
	"Afterglow (Gogh)",
	"Kanagawa (Gogh)",
	"MaterialDesignColors",
	"ChallengerDeep",
}
local lightThemes = {
	"Nord Light (Gogh)",
	"Ivory Light (terminal.sexy)",
	"Railscasts (light) (terminal.sexy)",
	"GoogleLight (Gogh)",
	"BlulocoZshLight (Gogh)",
}

local nordLight = wt.get_builtin_color_schemes()["Nord Light (Gogh)"]
nordLight.ansi[4] = "#c19a29" -- https://github.com/Gogh-Co/Gogh/blob/master/themes/Nord%20Light.yml
nordLight.brights[4] = "#DAB752"

local builtinSchemeOverrides = {
	["Nord Light (Gogh)"] = nordLight,
}

--------------------------------------------------------------------------------

local deviceSpecific = {
	home = {
		fontSize = 26.3,
		maxFps = 120,
		winPos = { x = 708, y = 0, w = 3135 },
	},
	office = {
		fontSize = 27.3,
		maxFps = 90,
		winPos = { x = 375, y = -100, w = 1675 },
	},
	mother = {
		fontSize = 24,
		maxFps = 30,
		winPos = { x = 620, y = 0, w = 2745 },
	},
}

--------------------------------------------------------------------------------

-- device specific config
local host = wt.hostname()
local device = "home"
if host:find("mini") or host:find("eduroam") then device = "office" end
if host:find("Mother") then device = "mother" end

-- set window position on startup
wt.on("gui-startup", function(cmd)
	-- on start, move window to the side ("pseudo-maximized")
	local pos = deviceSpecific[device].winPos
	local _, _, window = wt.mux.spawn_window(cmd or {})

	window:gui_window():set_position(pos.x, pos.y)
	local height = 3000 -- automatically truncated to maximum
	window:gui_window():set_inner_size(pos.w, height)
end)

--------------------------------------------------------------------------------
-- TAB & WINDOW TITLE

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
wt.on("format-tab-title", function(tab)
	-- prefer title that was set via `tab:set_title()` or `wezterm cli set-tab-title`
	local title = tab.tab_title ~= "" and tab.tab_title or tab.active_pane.title
	local cwd = tab.active_pane.current_working_dir
	local icon

	if cwd and (title == "zsh" or title == "wezterm" or title:find("/")) then
		local pwdBasefolder = cwd.file_path:gsub("^.*/(.*)/$", "%1")
		title = pwdBasefolder
		icon = "󰉋"
	elseif title:find("^docs") then
		icon = ""
	else
		icon = ""
	end

	return (" %s %s "):format(icon, title)
end)

--------------------------------------------------------------------------------
-- SETTINGS

local keymaps = require("wezterm-keymaps") -- my keymaps
local theme = require("theme-utils") -- my theme utils

local config = {
	-- Meta
	check_for_updates = false, -- done via homebrew already
	automatically_reload_config = true,

	-- Start/close
	default_cwd = wt.home_dir .. "/Desktop",
	window_close_confirmation = "NeverPrompt",
	quit_when_all_windows_are_closed = true,

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,
	default_cursor_style = "BlinkingBar", -- mostly overwritten by vi-mode.zsh
	cursor_thickness = "0.07cell",
	cursor_blink_rate = 700,
	cursor_blink_ease_in = "Constant", -- Constant = no fading
	cursor_blink_ease_out = "Constant",
	force_reverse_video_cursor = true, -- `true` = color is reverse, `false` = color by color scheme

	-- FONT
	font = wt.font { family = "JetBrainsMonoNL Nerd Font", weight = "Medium" },
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" }, -- disable ligatures
	cell_width = 0.9, -- effectively like letter-spacing
	font_size = deviceSpecific[device].fontSize,
	command_palette_font_size = deviceSpecific[device].fontSize,
	custom_block_glyphs = false, -- don't use wezterm's box-char replacements since too thin

	-- APPEARANCE
	color_schemes = builtinSchemeOverrides,
	color_scheme = theme.autoScheme(darkThemes[1], lightThemes[1]),
	window_background_opacity = 1,
	bold_brightens_ansi_colors = "BrightAndBold",
	max_fps = deviceSpecific[device].maxFps,
	adjust_window_size_when_changing_font_size = false,

	-- remove titlebar, but keep macOS traffic lights. Doing so enables some
	-- macOS window bar window-related functionality, like split commands
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
	scrollback_lines = 10000,

	-- Tabs
	enable_tab_bar = true,
	tab_max_width = 45, -- I have few tabs, therefore enough space for more width
	use_fancy_tab_bar = false, -- `false` makes the tabs bigger and more in terminal style
	show_new_tab_button_in_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	-- Mouse Bindings
	disable_default_mouse_bindings = false,
	mouse_bindings = {
		{ -- open link at normal leftclick & auto-copy selection if not a link
			event = { Up = { streak = 1, button = "Left" } },
			mods = "",
			action = wt.action.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard"),
		},
	},

	-- Bell
	audible_bell = "Disabled",
	visual_bell = { -- briefly flash cursor on visual bell
		fade_in_duration_ms = 500,
		fade_out_duration_ms = 500,
		target = "CursorColor",
	},

	-- Keybindings
	keys = keymaps.keys,
	key_tables = { copy_mode = keymaps.copymodeKeys },
	disable_default_key_bindings = true,
	send_composed_key_when_left_alt_is_pressed = true, -- fix @{}~ etc. on German keyboard
	send_composed_key_when_right_alt_is_pressed = true,
	use_dead_keys = true, -- do not expect another key after `^~`
}

return config
