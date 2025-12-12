local wt = require("wezterm")

---THEME------------------------------------------------------------------------
local darkThemes = { -- the first theme in each list is used
	"Kanagawa (Gogh)",
	"Darkside (Gogh)",
	"cyberpunk",
	"MaterialDesignColors",
	"Afterglow (Gogh)",
	"ChallengerDeep",
}
local lightThemes = {
	"Ura (Gogh)",
	"Novel (Gogh)",
	"GoogleLight (Gogh)",
	"Ivory Light (terminal.sexy)",
}

--------------------------------------------------------------------------------

wt.on("gui-startup", function(cmd)
	local sideAppWidth = 0.185
	local screenWidth = wt.gui.screens().main.width ---@diagnostic disable-line: undefined-field
	local x = screenWidth * sideAppWidth
	local _, _, win = wt.mux.spawn_window(cmd or {})
	win:gui_window():set_inner_size(9001, 9001) -- automatically truncated to maximum
	win:gui_window():set_position(x, 0)
end)

wt.on("format-tab-title", function(tab)
	-- set via `wezterm cli set-tab-title`
	if tab.tab_title ~= "" then return " " .. tab.tab_title .. " " end

	local winTitle = tab.active_pane.title -- set by procs like `nvim` or `yt-dlp --console-title`
	local pane = wt.mux.get_pane(tab.active_pane.pane_id)
	local cwd = pane:get_current_working_dir()
	local cwdPath = cwd and cwd.file_path:gsub("^.*/(.*)/$", "%1") or "---"
	local icon = winTitle == "zsh" and "" or ""
	local label = winTitle == "zsh" and cwdPath or winTitle
	return (" %s %s "):format(icon, label)
end)

---SETTINGS---------------------------------------------------------------------
local config = {
	-- Meta
	check_for_updates = true,
	automatically_reload_config = false, -- annoying with auto-save

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
	force_reverse_video_cursor = true, -- `true` = color is reversed, `false` = color by color scheme

	-- font
	font = wt.font { family = "JetBrainsMono Nerd Font", weight = "Medium" },
	cell_width = 0.9, -- effectively like letter-spacing
	font_size = 26.5,
	custom_block_glyphs = false, -- don't use wezterm's box-char replacements since too thin

	-- appearance
	color_scheme = wt.gui.get_appearance():find("Dark") and darkThemes[1] or lightThemes[1],
	window_background_opacity = 1,
	bold_brightens_ansi_colors = "BrightAndBold",
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
	use_fancy_tab_bar = false, -- `false` = style using terminal cells
	window_frame = { font_size = 30 }, -- font size if using `fancy_tab_bar`

	-- Bell
	audible_bell = "Disabled",
	visual_bell = { fade_in_duration_ms = 500, fade_out_duration_ms = 500, target = "CursorColor" },

	-- Mouse
	mouse_bindings = require("wezterm-keymaps").mouse,

	-- Keybindings
	keys = require("wezterm-keymaps").keys,
	key_tables = { search_mode = require("wezterm-keymaps").searchKeys },
	send_composed_key_when_left_alt_is_pressed = true, -- fix \@{}~ etc. on German keyboard
	send_composed_key_when_right_alt_is_pressed = true,
}

return config
