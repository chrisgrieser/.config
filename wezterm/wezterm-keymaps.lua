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

	-- scroll-to-prompt, requires shell integration: https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html
	{ key = "k", mods = "CTRL", action = act.ScrollToPrompt(-1) },
	{ key = "j", mods = "CTRL", action = act.ScrollToPrompt(1) },

	-- disable, since used for `fzf`
	{ key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment },

	---META----------------------------------------------------------------------
	{ key = ",", mods = "CMD", action = actFun(function() wt.open_with(wt.config_file) end) },
	{ key = "Escape", mods = "CTRL", action = act.ShowDebugOverlay },
	{ key = "t", mods = "CTRL", action = actFun(require("theme-cycler").cycle) },

	---BASIC KEYS----------------------------------------------------------------
	{ key = "v", mods = "CTRL", action = act.SplitHorizontal }, -- SIC actually vertical
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane { confirm = false } }, -- pane, then tab
	-- `cmd+n` should create new tab, not new window
	{ key = "n", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	-- clearing scrollback should also clear the viewport
	{ key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackAndViewport") },

	{ -- cycles panes, then tabs, then windows
		key = "Enter",
		mods = "CTRL",
		action = actFun(function(win, pane)
			local hasSplit = #pane:tab():panes() > 1
			local action = hasSplit and act.ActivatePaneDirection("Next") or act.ActivateTabRelative(1)
			win:perform_action(action, pane)
		end),
	},
	{
		key = "PageUp",
		action = actFun(function(win, pane)
			-- send key to fullscreen-TUI (like fzf), otherwise scroll https://github.com/wez/wezterm/discussions/4101
			local action = pane:is_alt_screen_active() and act.SendKey { key = "PageUp" }
				or act.ScrollByPage(-0.9)
			win:perform_action(action, pane)
		end),
	},
	{
		key = "PageDown",
		action = actFun(function(win, pane)
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
			patterns = {
				[[https?://[^\]",' ]+\w]], -- https-url
				"[a-f0-9]{7,40}", -- hashes
				"#[0-9]+", -- issues
			},
			label = "Open URL",
			action = actFun(function(win, pane)
				-- CAVEAT only works in my repos
				local githubUsername = "chrisgrieser"

				local match = win:get_selection_text_for_pane(pane)
				local cwd = pane:get_current_working_dir()
				local repoName = cwd and cwd.file_path:gsub("^.*/(.*)/$", "%1") or "NO CWD"
				local url
				if match:find("^%x+$") then
					wt.run_child_process { 'ls', '-l' }
					url = ("https://github.com/%s/%s/commit/%s"):format(githubUsername, repoName, match)
				elseif match:find("^#%d+$") then
					url = ("https://github.com/%s/%s/issues%s"):format(githubUsername, repoName, match)
				else
					url = match
				end
				wt.open_with(url)
			end),
		},
	},
}

---MOUSE------------------------------------------------------------------------
-- https://wezterm.org/config/mouse#configuring-mouse-assignments
M.mouse = {
	{ -- open link at normal leftclick & auto-copy selection if not a link
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard"),
	},
}

---SEARCH MODE------------------------------------------------------------------
-- cmd+g -> next/previous match, consistent with macOS behavior
M.searchKeys = wt.gui.default_key_tables().search_mode -- https://wezterm.org/scrollback.html#configurable-search-mode-key-assignments
table.insert(M.searchKeys, { key = "g", mods = "CMD", action = act.CopyMode("NextMatch") })
table.insert(M.searchKeys, { key = "g", mods = "CMD|SHIFT", action = act.CopyMode("PriorMatch") })

--------------------------------------------------------------------------------
return M
