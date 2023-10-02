local u = require("config.utils")
--------------------------------------------------------------------------------

-- default mappings: https://github.com/nvim-telescope/telescope.nvim/blob/942fe5faef47b21241e970551eba407bc10d9547/lua/telescope/mappings.lua#L133
local keymappings_I = {
	["<CR>"] = "select_default",
	["<Esc>"] = "close",
	["<PageDown>"] = "preview_scrolling_down",
	["<PageUp>"] = "preview_scrolling_up",
	["<Up>"] = "cycle_history_prev",
	["<Down>"] = "cycle_history_next",
	["<D-s>"] = "smart_send_to_qflist", -- sends selected, or if none selected, sends all
	["<Tab>"] = "move_selection_worse",
	["<S-Tab>"] = "move_selection_better",
	["<D-a>"] = "toggle_all",
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

local findFileMappings = {
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
	-- add `--hidden` & `--no-ignore`
	["<C-h>"] = function(prompt_bufnr)
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		-- cwd is only set if passed as telescope option
		local cwd = current_picker.cwd and tostring(current_picker.cwd) or vim.loop.cwd()

		require("telescope.actions").close(prompt_bufnr)
		require("telescope.builtin").find_files {
			prompt_title = vim.fs.basename(cwd) .. " (--hidden --no-ignore)",
			hidden = true,
			no_ignore = true,
			cwd = cwd,
		}
	end,
}

-- add j/k to mappings if normal mode
local keymappings_N = vim.deepcopy(keymappings_I)
keymappings_N["j"] = "move_selection_worse"
keymappings_N["k"] = "move_selection_better"

--------------------------------------------------------------------------------

local function telescopeConfig()
	-- https://github.com/nvim-telescope/telescope.nvim/issues/605
	local deltaPreviewer = require("telescope.previewers").new_termopen_previewer {
		get_command = function(entry)
			-- stylua: ignore
			return { "git", "-c", "core.pager=delta", "-c", "delta.side-by-side=false", "diff", entry.value .. "^!" }
		end,
	}

	-- color parent as Comment
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "TelescopeResults",
		callback = function()
			vim.fn.matchadd("TelescopeParent", "\t .*$")
			vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
		end,
	})

	require("telescope").setup {
		defaults = {
			path_display = function(_, path)
				-- parent is colored as a comment via autocmd further above
				local tail = vim.fs.basename(path)
				local parentBase = vim.fs.basename(vim.fs.dirname(path))
				if parentBase == "." then return tail end
				return string.format("%s\t %s", tail, parentBase)
			end,
			selection_caret = "󰜋 ",
			multi_icon = "󰒆 ",
			dynamic_preview_title = true,
			results_title = false,

			-- other ignores are defined via .gitignore, .ignore, or fd/ignore
			file_ignore_patterns = {
				"%.pdf$",
				"%.png$",
				"%.gif$",
				"%.jpe?g$",
				"%.icns$",
				"%.zip$",
				"%.pxd$",
				"%.plist$", -- mostly Alfred files
				".DS_Store", -- cause it is unignored in certain repos
			},
			preview = {
				timeout = 400, -- ms
				filesize_limit = 0.3, -- in MB, do not preview big files for performance
			},
			borderchars = u.borderChars,
			history = { path = u.vimDataDir .. "telescope_history" }, -- sync the history
			default_mappings = { i = keymappings_I, n = keymappings_N },
			sorting_strategy = "ascending", -- so layout is correctly orientated with prompt_position "top"
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "top",
					height = 0.75,
					width = 0.99,
					preview_cutoff = 70,
					preview_width = { 0.55, min = 30 },
				},
			},
		},
		pickers = {
			find_files = {
				prompt_prefix = "󰝰 ",
				-- FIX using the default find command from telescope is somewhat buggy,
				-- e.g. not respecting fd/ignore
				find_command = { "fd", "--type=file", "--type=symlink" },
				follow = true,
				hidden = false,
				mappings = { i = findFileMappings },
			},
			live_grep = { prompt_prefix = " ", disable_coordinates = true },
			git_status = {
				prompt_prefix = "󰊢 ",
				show_untracked = true,
				initial_mode = "normal",
			},
			git_commits = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
				results_title = "git log",
				previewer = deltaPreviewer,
				layout_config = { horizontal = { height = 0.9 } },
				-- add commit time (%cr)
				git_command = { "git", "log", "--pretty=%h %s (%cr)", "--", "." },
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
			loclist = {
				prompt_prefix = " ",
				trim_text = true,
				fname_width = 0,
			},
			lsp_document_symbols = {
				prompt_prefix = "󰒕 ",
				ignore_symbols = { "boolean", "number", "string" },
				fname_width = 12,
			},
			lsp_workspace_symbols = {
				prompt_prefix = "󰒕 ",
				ignore_symbols = { "string", "boolean", "number" },
				fname_width = 12,
			},
			buffers = {
				prompt_prefix = "󰽙 ",
				ignore_current_buffer = false,
				initial_mode = "normal",
				mappings = { n = { ["<D-w>"] = "delete_buffer" } },
				sort_mru = true,
				prompt_title = false,
				results_title = false,
				previewer = false,
				layout_config = {
					horizontal = { anchor = "W", width = 0.4, height = 0.5 },
				},
			},
			spell_suggest = {
				initial_mode = "normal",
				prompt_prefix = "󰓆",
				previewer = false,
				theme = "cursor",
				layout_config = { cursor = { width = 0.3 } },
			},
			colorscheme = {
				enable_preview = true,
				prompt_prefix = " ",
				results_title = false,
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
			smart_open = { match_algorithm = "fzf" },
			recent_files = {
				prompt_prefix = "󰋚 ",
				previewer = false,
				layout_config = {
					horizontal = { anchor = "W", width = 0.45, height = 0.55 },
				},
			},
		},
	}
end

return {
	{ -- fuzzy selector
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		config = telescopeConfig,
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
	{ -- better sorting algorithm
		"nvim-telescope/telescope-fzf-native.nvim",
		config = function() require("telescope").load_extension("fzf") end,
		build = "make",
	},
}
