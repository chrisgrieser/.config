-- DOCS
-- Actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
-- Key-Names: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments
--------------------------------------------------------------------------------

local M = {}
local wt = require("wezterm")
local act = wt.action
local actFun = wt.action_callback
--------------------------------------------------------------------------------

M.keys = {
	---ZSH BRIDGE----------------------------------------------------------------
	-- cmd+enter -> ctrl+o -> cycle common directories (configured in zshrc)
	{ key = "Enter", mods = "CMD", action = act.SendKey { key = "o", mods = "CTRL" } },

	-- cmd+l -> ctrl+l -> reveal current directory in Finder (configured in zshrc)
	{ key = "l", mods = "CMD", action = act.SendKey { key = "l", mods = "CTRL" } },

	-- shift-space -> daw -> delete a word (in vi-mode)
	{ key = "Space", mods = "SHIFT", action = act.SendString("daw") },

	{ -- insert line-break https://unix.stackexchange.com/a/80820
		key = "Enter",
		mods = "SHIFT",
		action = act.Multiple {
			act.SendKey { key = "v", mods = "CTRL" },
			act.SendKey { key = "j", mods = "CTRL" },
		},
	},

	---META----------------------------------------------------------------------
	{ key = ",", mods = "CMD", action = actFun(function() wt.open_with(wt.config_file) end) },
	{ key = "t", mods = "ALT", action = actFun(require("theme-cycler").cycle) },
	{ key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment }, -- used for `fzf`
	{ key = "Escape", mods = "CTRL", action = wt.action.ShowDebugOverlay }, -- REPL

	---TERMINAL KEYS-------------------------------------------------------------
	{ key = "p", mods = "CMD", action = act.ActivateCommandPalette },
	{ key = "v", mods = "CTRL", action = act.SplitHorizontal }, -- SIC actually vertical
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane { confirm = false } }, -- pane, then tab

	-- scroll-to-prompt, requires shell integration: https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html
	{ key = "k", mods = "CTRL", action = act.ScrollToPrompt(-1) },
	{ key = "j", mods = "CTRL", action = act.ScrollToPrompt(1) },

	{ -- cycles panes, then tabs, then windows
		key = "Enter",
		mods = "CTRL",
		action = wt.action_callback(function(win, pane)
			local hasSplit = #pane:tab():panes() > 1
			local action = hasSplit and act.ActivatePaneDirection("Next") or act.ActivateTabRelative(1)
			win:perform_action(action, pane)
		end),
	},
	{
		key = "PageUp",
		action = wt.action_callback(function(win, pane)
			-- send key to fullscreen-TUI (like fzf), otherwise scroll https://github.com/wez/wezterm/discussions/4101
			local action = pane:is_alt_screen_active() and act.SendKey { key = "PageUp" }
				or act.ScrollByPage(-0.9)
			win:perform_action(action, pane)
		end),
	},
	{
		key = "PageDown",
		action = wt.action_callback(function(win, pane)
			local action = pane:is_alt_screen_active() and act.SendKey { key = "PageDown" }
				or act.ScrollByPage(0.9)
			win:perform_action(action, pane)
		end),
	},
	{ -- cmd+e -> escaped backticks and (and move cursor into it)
		key = "e",
		mods = "CMD",
		action = act.Multiple {
			act.SendString([[\`\`]]),
			act.SendKey { key = "LeftArrow" },
			act.SendKey { key = "LeftArrow" },
		},
	},
	---HINT MODE (QUICK SELECT)--------------------------------------------------
	{ key = "y", mods = "CMD", action = act.QuickSelect }, -- https://wezfurlong.org/wezterm/quickselect.html

	{ -- cmd+shift+u -> open URL (like `f` in vimium)
		key = "u",
		mods = "CMD|SHIFT",
		action = act.QuickSelectArgs {
			patterns = { [[https?://[^\]",' ]+\w]] },
			label = "Open URL",
			action = actFun(function(win, pane)
				local url = win:get_selection_text_for_pane(pane)
				wt.open_with(url)
			end),
		},
	},
}

---SEARCH MODE------------------------------------------------------------------
-- cmd+g -> next/previous match, consistent with macOS behavior
M.searchKeys = wt.gui.default_key_tables().search_mode -- https://wezterm.org/scrollback.html#configurable-search-mode-key-assignments
table.insert(M.searchKeys, { key = "g", mods = "CMD", action = act.CopyMode("NextMatch") })
table.insert(M.searchKeys, { key = "g", mods = "CMD|SHIFT", action = act.CopyMode("PriorMatch") })

--------------------------------------------------------------------------------
return M
