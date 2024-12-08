-- DOCS
-- Actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
-- Key-Names: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments
--------------------------------------------------------------------------------

local M = {}
local wt = require("wezterm")
local act = wt.action
local actFun = wt.action_callback
local theme = require("theme-utils")
--------------------------------------------------------------------------------

M.keys = {
	{ key = "q", mods = "CMD", action = act.QuitApplication },
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "c", mods = "CMD", action = act.CopyTo("ClipboardAndPrimarySelection") },
	{ key = "h", mods = "CMD", action = act.HideApplication }, -- only macOS
	{ key = "+", mods = "CMD", action = act.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = act.ResetFontSize },
	{ key = "p", mods = "CMD", action = act.ActivateCommandPalette },
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane { confirm = false } },
	-- using `ctrl-L` instead of wezterm's scrollback-clearing preserves the
	-- ability to scroll back
	{ key = "k", mods = "CMD", action = act.SendKey { key = "l", mods = "CTRL" } },

	-- INFO using the mapping from the terminal_keybindings.zsh
	-- undo
	{ key = "z", mods = "CMD", action = act.SendKey { key = "n", mods = "CTRL" } },
	-- accept & execute suggestion
	{ key = "s", mods = "CMD", action = act.SendKey { key = "y", mods = "CTRL" } },

	{ -- cycles panes, then tabs, then windows
		key = "Enter",
		mods = "CTRL",
		action = wt.action_callback(function(win, pane)
			local paneCount = #pane:tab():panes()
			local tabCount = #win:mux_window():tabs()
			if paneCount > 1 then
				win:perform_action(act.ActivatePaneDirection("Next"), pane)
			elseif tabCount > 1 then
				win:perform_action(act.ActivateTabRelative(1), pane)
			else
				win:perform_action(act.ActivateTabRelative(1), pane)
			end
		end),
	},

	{
		key = "PageUp",
		action = wt.action_callback(function(win, pane)
			-- if TUI (such as fullscreen fzf), send key to TUI,
			-- otherwise scroll by page https://github.com/wez/wezterm/discussions/4101
			if pane:is_alt_screen_active() then
				win:perform_action(act.SendKey { key = "PageUp" }, pane)
			else
				win:perform_action(act.ScrollByPage(-0.8), pane)
			end
		end),
	},
	{
		key = "PageDown",
		action = wt.action_callback(function(win, pane)
			if pane:is_alt_screen_active() then
				win:perform_action(act.SendKey { key = "PageDown" }, pane)
			else
				win:perform_action(act.ScrollByPage(0.8), pane)
			end
		end),
	},

	{ -- for adding inline code to a commit, hotkey consistent with GitHub
		key = "e",
		mods = "CMD",
		action = act.Multiple {
			act.SendString([[\`\`]]),
			act.SendKey { key = "LeftArrow" },
			act.SendKey { key = "LeftArrow" },
		},
	},
	-- REMAP: Grappling Hook (cannot use `bindkey` for `<D-CR>`)
	{ key = "Enter", mods = "CMD", action = act.SendKey { key = "o", mods = "CTRL" } },

	-- REMAP: VI MODE (cannot use `bindkey` for `<S-Space>`)
	{ key = "Space", mods = "SHIFT", action = act.SendString("daw") },

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

	-- HINT MODE (= Quick Select) -- https://wezfurlong.org/wezterm/quickselect.html
	{ key = "y", mods = "CMD", action = act.QuickSelect },

	{ -- cmd+u -> open URL (like f in vimium)
		key = "u",
		mods = "CMD",
		action = act.QuickSelectArgs {
			patterns = { [[https?://[^\]",' ]+\w]] },
			label = "Open URL",
			action = actFun(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wt.open_with(url)
			end),
		},
	},
	{ -- cmd+o -> copy [o]ption (e.g. from a man page)
		key = "o",
		mods = "CMD",
		action = act.QuickSelectArgs {
			patterns = { "--[\\w=-]+", "(?<= )-\\w" }, -- long option, short option
			label = "Copy shell option",
		},
	},

	-----------------------------------------------------------------------------

	-- OTHER MODES
	-- Search
	{ key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },

	-- Console / REPL
	{ key = "Escape", mods = "CTRL", action = wt.action.ShowDebugOverlay },

	-- Copy Mode (= Caret Mode) -- https://wezfurlong.org/wezterm/copymode.html
	{ key = "c", mods = "CMD|SHIFT", action = act.ActivateCopyMode },

	-----------------------------------------------------------------------------

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
