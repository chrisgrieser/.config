-- Actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
-- Key-Names: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments

local wt = require("wezterm")
local act = wt.action
local actFun = wt.action_callback
local theme = require("theme-utils")

--------------------------------------------------------------------------------

local M = {}

M.keys = {
	{ key = "q", mods = "CMD", action = act.QuitApplication },
	{ key = "w", mods = "CMD", action = act.CloseCurrentTab { confirm = false } },
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "c", mods = "CMD", action = act.CopyTo("ClipboardAndPrimarySelection") },
	{ key = "h", mods = "CMD", action = act.HideApplication }, -- only macOS
	{ key = "+", mods = "CMD", action = act.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = act.ResetFontSize },
	{ key = "p", mods = "CMD", action = act.ActivateCommandPalette },
	{ key = "ö", mods = "CMD", action = act.CharSelect },

	-- using `ctrl-L` instead of wezterm's scrollback-clearing preserves the
	-- abilite to scroll back
	{ key = "k", mods = "CMD", action = act.SendKey { key = "l", mods = "CTRL" } },

	{ key = "Enter", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
	{
		key = "PageUp",
		action = wt.action_callback(function(win, pane)
			-- if TUI, send key to TUI, else scroll by page https://github.com/wez/wezterm/discussions/4101
			if pane:is_alt_screen_active() then
				win:perform_action(wt.action.SendKey { key = "PageUp" }, pane)
			else
				win:perform_action(wt.action.ScrollByPage(-0.8), pane)
			end
		end),
	},
	{
		key = "PageDown",
		action = wt.action_callback(function(win, pane)
			if pane:is_alt_screen_active() then -- TUI
				win:perform_action(wt.action.SendKey { key = "PageDown" }, pane)
			else
				win:perform_action(wt.action.ScrollByPage(0.8), pane)
			end
		end),
	},

	-- INFO using the mapping from the terminal_keybindings.zsh
	-- undo (ctrl-z set in terminal keybindings)
	{ key = "z", mods = "CMD", action = act.SendKey { key = "z", mods = "CTRL" } },
	{ -- for adding inline code to a commit, hotkey consistent with GitHub
		key = "e",
		mods = "CMD",
		action = act.Multiple {
			act.SendString([[\`\`]]),
			act.SendKey { key = "LeftArrow" },
			act.SendKey { key = "LeftArrow" },
		},
	},
	-- Grappling-hook
	{ key = "Enter", mods = "CMD", action = act.SendKey { key = "o", mods = "CTRL" } },

	{ -- insert line-break https://unix.stackexchange.com/a/80820
		key = "Enter",
		mods = "SHIFT",
		action = act.Multiple {
			act.SendKey { key = "v", mods = "CTRL" },
			act.SendKey { key = "j", mods = "CTRL" },
		},
	},

	-- scroll-to-prompt, requires shell integration: https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html
	{ key = "k", mods = "CTRL", action = act.ScrollToPrompt(-1) },
	{ key = "j", mods = "CTRL", action = act.ScrollToPrompt(1) },

	-- FIX works with `send_composed_key_when_right_alt_is_pressed = true`
	-- but expects another character, so this mapping fixes it
	{ key = "n", mods = "ALT", action = act.SendString("~") },
	-- FIX keychron K3V2 bug
	{ key = "<", action = act.SendString("^") },
	{ key = "^", action = act.SendString("<") },

	-- Emulates macOS' cmd-right & cmd-left
	{ key = "LeftArrow", mods = "CMD", action = act.SendKey { key = "A", mods = "CTRL" } },
	{ key = "RightArrow", mods = "CMD", action = act.SendKey { key = "E", mods = "CTRL" } },

	{ -- cmd+l -> open current location in Finder
		key = "l",
		mods = "CMD",
		action = actFun(function(_, pane)
			local cwd = pane:get_current_working_dir().file_path
			wt.open_with(cwd, "Finder")
		end),
	},
	-- Theme Cycler
	{ key = "t", mods = "ALT", action = actFun(theme.cycle) },

	-----------------------------------------------------------------------------

	-- MODES
	-- Search
	{ key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },

	-- Console / REPL
	{ key = "Escape", mods = "CTRL", action = wt.action.ShowDebugOverlay },

	-- Copy Mode (= Caret Mode) -- https://wezfurlong.org/wezterm/copymode.html
	{ key = "y", mods = "CMD", action = act.ActivateCopyMode },

	-- Quick Select (= Hint Mode) -- https://wezfurlong.org/wezterm/quickselect.html
	{ key = "u", mods = "CMD", action = act.QuickSelect },

	{ -- cmd+o -> copy [o]ption (e.g. from a man page)
		key = "o",
		mods = "CMD",
		action = act.QuickSelectArgs {
			patterns = { "--[\\w=-]+", "-\\w" }, -- long option, short option
			label = "Copy Shell Option",
		},
	},
	{ -- cmd+, -> open the config file
		key = ",",
		mods = "CMD",
		action = actFun(function() wt.open_with(wt.config_file) end),
	},
	{ -- cmd+shift+, -> open the keybindings file (this file)
		key = ";",
		mods = "CMD|SHIFT",
		action = actFun(function()
			local thisFile = wt.config_file:gsub("wezterm%.lua$", "wezterm-keymaps.lua")
			wt.open_with(thisFile)
		end),
	},
}

--------------------------------------------------------------------------------
-- COPYMODE
-- DOCS https://wezfurlong.org/wezterm/config/lua/wezterm.gui/default_key_tables.html
M.copymodeKeys = wt.gui.default_key_tables().copy_mode

-- HJKL like hjkl, but bigger distance
local myCopyModeKeys = {
	{ key = "l", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
	{ key = "h", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
	{ key = "j", mods = "SHIFT", action = act.CopyMode { MoveByPage = 0.33 } },
	{ key = "k", mods = "SHIFT", action = act.CopyMode { MoveByPage = -0.33 } },
}

for _, key in ipairs(myCopyModeKeys) do
	table.insert(M.copymodeKeys, key)
end

--------------------------------------------------------------------------------
return M
