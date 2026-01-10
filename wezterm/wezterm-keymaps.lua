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

	-- cmd+z -> ctrl+z -> undo
	{ key = "z", mods = "CMD", action = act.SendKey { key = "z", mods = "CTRL" } },

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

	-- semantic-zone-interaction, requires shell integration: https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html
	{ key = "k", mods = "CTRL", action = act.ScrollToPrompt(-1) },
	{ key = "j", mods = "CTRL", action = act.ScrollToPrompt(1) },

	-- disable, since used for `fzf`
	{ key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment },

	-- emulate macOS' cmd+right-arrow & cmd+left-arrow
	{ key = "LeftArrow", mods = "CMD", action = act.SendKey { key = "a", mods = "CTRL" } },
	{ key = "RightArrow", mods = "CMD", action = act.SendKey { key = "e", mods = "CTRL" } },

	---META----------------------------------------------------------------------
	{ key = ",", mods = "CMD", action = actFun(function() wt.open_with(wt.config_file) end) },
	{ key = "Escape", mods = "CTRL", action = act.ShowDebugOverlay },
	{ key = "t", mods = "CTRL", action = actFun(require("theme-cycler").cycle) },

	---BASIC KEYS----------------------------------------------------------------
	{ key = "p", mods = "CMD", action = act.ActivateCommandPalette },
	{ key = "+", mods = "CMD", action = act.IncreaseFontSize }, -- FIX not using `=`
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

	{ -- cmd+o -> open URL (like `f` in vimium)
		key = "o",
		mods = "CMD",
		action = act.QuickSelectArgs {
			label = "Open file/url/commit/issue",
			-- skip_action_on_paste = true, -- in next release
			patterns = {
				[[https?://[^\]",' ]+\w]], -- regular URLs
				[[[^'"]+/[^'"]+\.\w{2,4}]], -- absolute or relative path (no quotes allowed in file name)
				"[a-f0-9]{7,40}", -- commits
				"(?<=#)[0-9]{1,6}", -- issues (the `#` excluded due to the lookbehind)
			},
			action = actFun(function(win, pane)
				local match = win:get_selection_text_for_pane(pane)
				local cwd = (pane:get_current_working_dir() or {}).file_path

				-- url
				if match:find("^https?://") then return wt.open_with(match) end

				-- absolute path of a file
				if match:find("^/") then return wt.open_with(match) end

				if not cwd then return wt.log_info("No cwd found.") end

				-- relative path of a file
				if match:find("/") then return wt.open_with(cwd .. "/" .. match) end

				-- commit or issue
				local type = #match < 7 and "issues" or "commit"
				local ok, stdout, stderr =
					wt.run_child_process { "git", "-C", cwd, "remote", "--verbose" }
				if not ok then return wt.log_info("remote info failed:", stderr) end
				local repo = (stdout:match("github%.com[/:](%S+)") or ""):gsub("%.git$", "")
				if repo == "" then return wt.log_info("remote info has no github url:", stdout) end
				local url = ("https://github.com/%s/%s/%s"):format(repo, type, match)
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
