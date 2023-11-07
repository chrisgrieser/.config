local u = require("config.utils")
local telescope = vim.cmd.Telescope

--------------------------------------------------------------------------------
-- MAPPINGS

-- default mappings: https://github.com/nvim-telescope/telescope.nvim/blob/942fe5faef47b21241e970551eba407bc10d9547/lua/telescope/mappings.lua#L133
local keymappings_I = {
	["<Tab>"] = "move_selection_worse",
	["<S-Tab>"] = "move_selection_better",
	["<CR>"] = "select_default",
	["<Esc>"] = "close",
	["<PageDown>"] = "preview_scrolling_down",
	["<PageUp>"] = "preview_scrolling_up",
	["<Up>"] = "cycle_history_prev",
	["<Down>"] = "cycle_history_next",
	["<D-a>"] = "toggle_all",
	["<D-s>"] = function(prompt_bufnr)
		require("telescope.actions").smart_send_to_qflist(prompt_bufnr) -- sends selected, or if none selected, sends all
		vim.cmd.cfirst()
	end,
	["<D-CR>"] = function(prompt_bufnr)
		require("telescope.actions").toggle_selection(prompt_bufnr)
		require("telescope.actions").move_selection_worse(prompt_bufnr)
	end,
	["<D-l>"] = function(prompt_bufnr)
		-- Reveal File in macOS Finder
		local path = require("telescope.actions.state").get_selected_entry().value
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.system { "open", "-R", path }
	end,
	["<C-p>"] = function(prompt_bufnr)
		-- Copy path of file -- https://github.com/nvim-telescope/telescope-file-browser.nvim/issues/191
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		local cwd = current_picker.cwd and tostring(current_picker.cwd) or vim.loop.cwd()
		local path = require("telescope.actions.state").get_selected_entry().value
		local fullpath = cwd .. "/" .. path
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", fullpath)
		u.notify("Copied", fullpath)
	end,
	["<C-n>"] = function(prompt_bufnr)
		-- Copy name of file -- https://github.com/nvim-telescope/telescope-file-browser.nvim/issues/191
		local path = require("telescope.actions.state").get_selected_entry().value
		local name = vim.fs.basename(path)
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", name)
		u.notify("Copied", name)
	end,
}

local hiddenIgnoreActive = false
local findFileMappings = {
	-- toggle `--hidden` & `--no-ignore`
	["<C-h>"] = function(prompt_bufnr)
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		-- cwd is only set if passed as telescope option
		local cwd = current_picker.cwd and tostring(current_picker.cwd) or vim.loop.cwd()
		hiddenIgnoreActive = not hiddenIgnoreActive
		local title = vim.fs.basename(cwd)
		if hiddenIgnoreActive then title = title .. " (--hidden --no-ignore)" end

		require("telescope.actions").close(prompt_bufnr)
		require("telescope.builtin").find_files {
			prompt_title = title,
			hidden = hiddenIgnoreActive,
			no_ignore = hiddenIgnoreActive,
			cwd = cwd,
			file_ignore_patterns = { "%.DS_Store$", "%.git/" }, -- prevent these becoming visible through `--no-ignore`
		}
	end,
	-- search directory up
	["<D-up>"] = function(prompt_bufnr)
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		-- cwd is only set if passed as telescope option
		local cwd = current_picker.cwd and tostring(current_picker.cwd) or vim.loop.cwd()
		local parent_dir = vim.fs.dirname(cwd)

		require("telescope.actions").close(prompt_bufnr)
		require("telescope.builtin").find_files {
			prompt_title = vim.fs.basename(parent_dir),
			cwd = parent_dir,
		}
	end,
}

-- add j/k/q to mappings if normal mode
local normalModeOnly = {
	["j"] = "move_selection_worse",
	["k"] = "move_selection_better",
	["q"] = {
		-- extra stuff needed to be able to set `nowait` for `q`
		function(prompt_bufnr) require("telescope.actions").close(prompt_bufnr) end,
		type = "action",
		opts = { nowait = true },
	},
}
local keymappings_N = vim.tbl_extend("force", keymappings_I, normalModeOnly)

--------------------------------------------------------------------------------
-- HELPERS

-- https://github.com/nvim-telescope/telescope.nvim/issues/605
local function deltaPreviewer()
	return require("telescope.previewers").new_termopen_previewer {
		get_command = function(entry)
			local pager = vim.fn.system { "git", "config", "core.pager" }
			if not pager:find("^delta") then return { "echo", "pager not set to delta" } end

			local gitroot = vim.trim(vim.fn.system { "git", "rev-parse", "--show-toplevel" })
			local filename = entry.value
			local filepath = gitroot .. "/" .. filename
			-- stylua: ignore
			return { "git", "-c", "delta.file-style=omit" --[[only 1 file anyway]] , "diff", filepath }
		end,
	}
end

local function gitDiffStatPreviewer()
	return require("telescope.previewers").new_termopen_previewer {
		dyn_title = function(_, entry) return entry.value end, -- use hash as title
		get_command = function(entry, status)
			local hash = entry.value
			local previewWinWidth = vim.api.nvim_win_get_width(status.preview_win)
			local statArgs = ("%s,%s,25"):format(previewWinWidth, math.floor(previewWinWidth / 2))
			local previewFormat =
				"%C(bold)%C(magenta)%s %n%C(reset)%C(cyan)%D%C(reset)%b %n%C(blue)%an %C(yellow)(%ch) %C(reset)"
			local cmd = {
				"git show " .. hash,
				"--color=always",
				"--stat=" .. statArgs,
				"--format='" .. previewFormat .. "'",
				"| sed -e 's/^ //' -e '$d' ;", -- remove clutter
			}
			return table.concat(cmd, " ")
		end,
	}
end

-- HACK color parent as comment
-- CAVEAT interferes with other Telescope Results that display for spaces
vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopeResults",
	callback = function()
		vim.fn.matchadd("TelescopeParent", "    .*$")
		vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
	end,
})

---Requires the autocmd above
---@param _ table
---@param path string
---@return string
local function pathDisplay(_, path)
	path = path:gsub("/$", "") -- trailing slash from directories breaks fs.basename
	local tail = vim.fs.basename(path)
	local parent = vim.fs.dirname(path)
	if parent == "." then return tail end
	local parentDisplay = #parent > 20 and vim.fs.basename(parent) or parent
	return string.format("%s    %s", tail, parentDisplay) -- parent colored via autocmd above
end

--------------------------------------------------------------------------------

local telescopeConfig = {
	defaults = {
		path_display = pathDisplay,
		selection_caret = "󰜋 ",
		multi_icon = "󰒆 ",
		results_title = false,
		dynamic_preview_title = true,
		preview = {
			timeout = 400, -- ms
			filesize_limit = 1, -- Mb
			ls_short = true, -- ls is only used when displaying directories
		},
		borderchars = u.borderChars,
		default_mappings = { i = keymappings_I, n = keymappings_N },
		sorting_strategy = "ascending", -- so layout is consistent with prompt_position "top"
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				prompt_position = "top",
				height = { 0.75, min = 13 },
				width = 0.99,
				preview_cutoff = 70,
				preview_width = { 0.55, min = 30 },
			},
		},
		-- stylua: ignore
		file_ignore_patterns = {
			"%.pdf$", "%.png$", "%.gif$", "%.jpe?g$","%.icns$", "%.pxd$",
			"%.zip$", "%.plist$",
			-- other ignores are defined via .gitignore, .ignore, /fd/ignore, or /git/ignore
		},
	},
	pickers = {
		find_files = {
			prompt_prefix = "󰝰 ",
			-- FIX using the default find command from telescope is somewhat buggy,
			-- e.g. not respecting /fd/ignore
			find_command = { "fd", "--type=file", "--type=symlink" },
			mappings = { i = findFileMappings },
		},
		live_grep = { prompt_prefix = " ", disable_coordinates = true },
		git_status = {
			prompt_prefix = "󰊢 ",
			show_untracked = true,
			initial_mode = "normal",
			previewer = deltaPreviewer(),
			layout_config = { horizontal = { height = 0.99 } },
			mappings = {
				n = {
					["<Tab>"] = "move_selection_worse",
					["<S-Tab>"] = "move_selection_better",
					["<D-CR>"] = "git_staging_toggle",
				},
			},
		},
		git_commits = {
			prompt_prefix = "󰊢 ",
			initial_mode = "normal",
			prompt_title = "Git Log",
			previewer = gitDiffStatPreviewer(),
			layout_config = { horizontal = { height = 0.99 } },
			-- add commit time (%cr) & `--all`
			git_command = { "git", "log", "--all", "--pretty=%h %s\t%cr", "--", "." },
		},
		git_bcommits = {
			prompt_prefix = "󰊢 ",
			initial_mode = "normal",
			layout_config = { horizontal = { height = 0.99 } },
			git_command = { "git", "log", "--pretty=%h %s\t%cr" }, -- add commit time (%cr)
		},
		keymaps = {
			prompt_prefix = " ",
			modes = { "n", "i", "c", "x", "o", "t" },
			show_plug = false, -- do not show mappings with "<Plug>"
			lhs_filter = function(lhs) return not lhs:find("Þ") end, -- remove which-key mappings
		},
		highlights = {
			prompt_prefix = " ",
			layout_config = {
				horizontal = { preview_width = { 0.7, min = 30 } },
			},
		},
		lsp_workspace_symbols = {
			prompt_prefix = "󰒕 ",
			prompt_title = "Functions",
			-- stylua: ignore
			ignore_symbols = { "boolean", "number", "string", "variable", "array", "object", "constant", "package" },
			fname_width = 12,
		},
		buffers = {
			prompt_prefix = "󰽙 ",
			ignore_current_buffer = false,
			sort_mru = true,
			initial_mode = "normal",
			mappings = { n = { ["<D-w>"] = "delete_buffer" } },
			previewer = false,
			layout_config = {
				horizontal = { anchor = "W", width = 0.5, height = 0.5 },
			},
		},
		colorscheme = {
			enable_preview = true,
			prompt_prefix = " ",
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					height = 0.4,
					width = 0.3,
					anchor = "SE",
					preview_width = 1, -- needs preview for live preview of the theme
				},
			},
		},
	},
	extensions = {
		recent_files = {
			prompt_prefix = "󰋚 ",
			previewer = false,
			layout_config = {
				horizontal = { anchor = "W", width = 0.5, height = 0.55 },
			},
		},
		aerial = {
			show_nesting = {
				markdown = false,
				["_"] = true,
			},
		},
	},
}

--------------------------------------------------------------------------------

---@return string name of the current project
local function projectName()
	local pwd = vim.loop.cwd() or ""
	return vim.fs.basename(pwd)
end

return {
	{ -- fuzzy finder
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{ "?", function() telescope("keymaps") end, desc = "⌨️  Search Keymaps" },
			{ "gb", function() telescope("buffers") end, desc = " 󰽙 Buffers" },
			{ "g.", function() telescope("resume") end, desc = " Continue" },
			{
				"gw",
				function() telescope("lsp_workspace_symbols") end,
				desc = "󰒕 Workspace Symbols",
			},
			{ "<leader>pg", function() telescope("highlights") end, desc = " Highlight Groups" },
			{
				"<leader>pc",
				function() telescope("colorscheme") end,
				desc = " Change Colorschemes",
			},
			{ "<leader>gs", function() telescope("git_status") end, desc = " Status" },
			{ "<leader>gl", function() telescope("git_commits") end, desc = " Log/Commits" },
			{ "<leader>gL", function() telescope("git_bcommits") end, desc = " Buffer Commits" },
			{ "<leader>gb", function() telescope("git_branches") end, desc = " Branches" },
			{
				"go",
				function()
					require("telescope.builtin").find_files {
						prompt_title = "Find Files: " .. projectName(),
					}
				end,
				desc = " Browse in Project",
			},
			{
				"gl",
				function()
					require("telescope.builtin").live_grep {
						prompt_title = "Live Grep: " .. projectName(),
					}
				end,
				desc = " Live-Grep in Project",
			},
			{ "gL", function() telescope("grep_string") end, desc = " Grep cword in Project" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		opts = telescopeConfig,
	},
	{ -- Icon Picker
		"nvim-telescope/telescope-symbols.nvim",
		keys = {
			{
				"<D-ö>",
				mode = { "n", "i" },
				function()
					require("telescope.builtin").symbols {
						sources = { "nerd", "math" },
						layout_config = { horizontal = { width = 0.35, height = 0.55 } },
					}
				end,
				desc = " Icon Picker",
			},
		},
	},
	{ -- better recent files
		"smartpde/telescope-recent-files",
		dependencies = "nvim-telescope/telescope.nvim",
		config = function() require("telescope").load_extension("recent_files") end,
		keys = {
			{
				"gr",
				function() require("telescope").extensions.recent_files.pick() end,
				desc = " Recent Files",
			},
		},
	},
	{ -- ast-grep search
		"Marskey/telescope-sg",
		dependencies = "nvim-telescope/telescope.nvim",
		config = function() require("telescope").load_extension("ast_grep") end,
		keys = {
			{ "gS", function() telescope("ast_grep") end, desc = " Ast-Grep" },
		},
	},
	{ -- better sorting algorithm + fzf syntax
		"nvim-telescope/telescope-fzf-native.nvim",
		config = function() require("telescope").load_extension("fzf") end,
		build = "make",
	},
}
