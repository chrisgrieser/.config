local wt = require("wezterm")

---THEME------------------------------------------------------------------------
local darkThemes = { -- the first theme in each list is used
	"Kanagawa (Gogh)",
	"cyberpunk",
	"MaterialDesignColors",
	"Afterglow (Gogh)",
	"ChallengerDeep",
}
local lightThemes = {
	"GoogleLight (Gogh)",
	"Ivory Light (terminal.sexy)",
}

---DEVICE-SPECIFIC--------------------------------------------------------------
local deviceSpecific = {
	home = {
		fontSize = 26.3,
		maxFps = 120,
		winPos = { x = 708, y = 0, w = 3135 },
	},
	office = {
		fontSize = 27.3,
		maxFps = 90,
		winPos = { x = 375, y = 0, w = 1675 },
	},
	mother = {
		fontSize = 24,
		maxFps = 30,
		winPos = { x = 620, y = 0, w = 2745 },
	},
}

-- device specific config
local host = wt.hostname()
local device = "home"
if host:find("mini") or host:find("eduroam") then device = "office" end
if host:find("Mother") then device = "mother" end

-- on start, move window to the side ("pseudo-maximized")
wt.on("gui-startup", function(cmd)
	local pos = deviceSpecific[device].winPos
	local _, _, window = wt.mux.spawn_window(cmd or {})
	window:gui_window():set_position(pos.x, pos.y)
	local height = 3000 -- automatically truncated to maximum
	window:gui_window():set_inner_size(pos.w, height)
end)

---TAB TITLE--------------------------------------------------------------------
-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
wt.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, _max_width)
	if tab.tab_title ~= "" then return tab.tab_title end -- set via `wezterm cli set-tab-title`
	local winTitle = tab.active_pane.title -- set procs like `nvim` or `yt-dlp --console-title`
	local pane = wt.mux.get_pane(tab.active_pane.pane_id)
	local cwd = pane:get_current_working_dir().file_path:gsub("^.*/(.*)/$", "%1")
	local icon = winTitle == "zsh" and "" or ""
	local label = winTitle == "zsh" and cwd or winTitle
	return (" %s %s "):format(icon, label)
end)

---SETTINGS---------------------------------------------------------------------
local config = {
	-- Meta
	check_for_updates = true,
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

	-- font
	font = wt.font { family = "JetBrainsMono Nerd Font", weight = "Medium" },
	cell_width = 0.9, -- effectively like letter-spacing
	font_size = deviceSpecific[device].fontSize,
	command_palette_font_size = deviceSpecific[device].fontSize,
	custom_block_glyphs = false, -- don't use wezterm's box-char replacements since too thin

	-- appearance
	color_scheme = wt.gui.get_appearance():find("Dark") and darkThemes[1] or lightThemes[1],
	window_background_opacity = 1,
	bold_brightens_ansi_colors = "BrightAndBold",
	max_fps = deviceSpecific[device].maxFps,
	adjust_window_size_when_changing_font_size = false,

	-- remove titlebar, but keep macOS traffic lights. Doing so enables some
	-- macOS window bar window-related functionality, like split commands
	-- (used by Hammerspoon)
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",

	-- Scroll & Scrollbar
	enable_scroll_bar = true,
	window_padding = {
		left = "0.5cell",
		right = "1.1cell", -- if scrollbar enabled, "right" controls scrollbar width
		top = "1cell", -- extra height to account for macOS traffic lights
		bottom = "0.3cell",
	},
	min_scroll_bar_height = "3cell",
	scrollback_lines = 10000,

	-- Tabs
	enable_tab_bar = true,
	show_new_tab_button_in_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	tab_max_width = 90,
	use_fancy_tab_bar = false, -- `false` = style using terminal cells
	window_frame = { font_size = 30 }, -- font size if using `fancy_tab_bar`

	-- Mouse
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
	keys = require("wezterm-keymaps").keys,
	key_tables = { search_mode = require("wezterm-keymaps").searchKeys },
	send_composed_key_when_left_alt_is_pressed = true, -- fix \@{}~ etc. on German keyboard
	send_composed_key_when_right_alt_is_pressed = true,
}

return config
