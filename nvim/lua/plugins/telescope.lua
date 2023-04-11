local u = require("config.utils")
--------------------------------------------------------------------------------

local keymappings = {
	-- INFO default mappings: https://github.com/nvim-telescope/telescope.nvim/blob/942fe5faef47b21241e970551eba407bc10d9547/lua/telescope/mappings.lua#L133
	["<Esc>"] = "close",
	["<PageDown>"] = "preview_scrolling_down",
	["<PageUp>"] = "preview_scrolling_up",
	["<C-h>"] = "cycle_history_prev",
	["<C-l>"] = "cycle_history_next",
	-- INFO remapped from ^ via karabiner
	["<f1>"] = "smart_send_to_qflist", -- sends selected, or if none selected, sends all
	["<D-a>"] = "select_all",
	["<Tab>"] = "move_selection_worse",
	["<S-Tab>"] = "move_selection_better",
	["<D-CR>"] = function(prompt_bufnr)
		require("telescope.actions").toggle_selection(prompt_bufnr)
		require("telescope.actions").move_selection_worse(prompt_bufnr)
	end,
	["?"] = "which_key",
}

local function telescopeConfig()
	require("telescope").setup {
		defaults = {
			selection_caret = "󰜋 ",
			prompt_prefix = "❱ ",
			multi_icon = "󰒆 ",
			preview = { filesize_limit = 1 }, -- in MB, do not preview big files for performance
			path_display = { "tail" }, -- smart|tail (rest isn't that useful)
			borderchars = require("config.utils").borderChars,
			history = { path = u.vimDataDir .. "telescope_history" }, -- sync the history
			file_ignore_patterns = {
				"%.git/",
				"%.git$", -- git dir in submodules
				"node_modules/", -- node
				"venv/", -- python
				"%.app/", -- internals of mac apps
				"%.pxd", -- Pixelmator
				"%.plist$", -- Alfred
				"%.harpoon$", -- harpoon/projects
				"/INFO ", -- custom info files
				"%.png$",
				"%.gif$",
				"%.jpe?g$",
				"%.icns",
				"%.zip$",
				"%.mkv$",
				"%.mp4$",
			},
			mappings = {
				i = keymappings,
				n = keymappings,
			},
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--trim", -- this added to trim results
			},
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					height = 0.85,
					width = 0.9,
					preview_cutoff = 70,
					preview_width = { 0.50, min = 30 },
				},
				cursor = {
					preview_cutoff = 9001, -- never use preview here
					height = 1,
				},
			},
		},
		pickers = {
			git_status = { prompt_prefix = "󰊢 ", show_untracked = true },
			git_commits = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
				-- adding "--all" to see future commits as well
				git_command = { "git", "log", "--all", "--pretty=oneline", "--abbrev-commit", "--", "." },
			},
			git_bcommits = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
				-- adding "--all" to see future commits as well
				git_command = { "git", "log", "--all", "--pretty=oneline", "--abbrev-commit" },
			},
			keymaps = {
				prompt_prefix = " ",
				modes = { "n", "i", "c", "x", "o", "t" },
				-- do not show mappings with "<Plug>"
				show_plug = false,
				-- remove which-key mappings
				lhs_filter = function (lhs) return not lhs:find("Þ") end,
			},
			diagnostics = { prompt_prefix = "󰒕 ", no_sign = true },
			treesitter = { prompt_prefix = " ", show_line = false },
			oldfiles = { prompt_prefix = "󰋚 " },
			highlights = { prompt_prefix = " " },
			loclist = { prompt_prefix = " ", trim_text = true },
			live_grep = { prompt_prefix = " ", disable_coordinates = true },
			grep_string = { prompt_prefix = " ", disable_coordinates = true },
			command_history = {
				prompt_prefix = "󰘳 ",
				mappings = { i = { ["<D-CR>"] = "edit_command_line" } },
			},
			lsp_document_symbols = {
				prompt_prefix = "󰒕 ",
				-- markdown headings are symbol-type "string", therefore shouldn't
				-- be ignored
				ignore_symbols = { "boolean", "number" },
				fname_width = 17,
			},
			lsp_workspace_symbols = {
				prompt_prefix = "󰒕 ",
				ignore_symbols = { "string", "boolean", "number" },
				fname_width = 17,
			},
			buffers = {
				prompt_prefix = "󰽙 ",
				ignore_current_buffer = false,
				initial_mode = "normal",
				mappings = { n = { ["<D-w>"] = "delete_buffer" } },
				sort_mru = true,
				prompt_title = false,
				results_title = false,
				theme = "cursor",
				layout_config = { cursor = { width = 0.5, height = 0.4 } },
			},
			spell_suggest = {
				initial_mode = "normal",
				prompt_prefix = "󰓆",
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
						height = 0.3,
						width = 0.3,
						anchor = "SE",
						preview_width = 1, -- needs preview for live preview of the theme
					},
				},
			},
		},
		extensions = {
			file_browser = {
				prompt_prefix = " ",
				depth = 2, -- initial depth (1 = only current folder)
				auto_depth = true, -- unlimited depth as soon as prompt is non-empty
				hidden = true,
				display_stat = false,
				git_status = true, -- seems to sometimes be buggy
				group = true,
				hide_parent_dir = true,
				select_buffer = true,
				mappings = {
					i = {
						-- mappings should be consistent with nvim-ghengis mappings
						["<D-n>"] = require("telescope._extensions.file_browser.actions").create,
						["<C-r>"] = require("telescope._extensions.file_browser.actions").rename,
						["<D-BS>"] = require("telescope._extensions.file_browser.actions").remove,
						-- Toggle Files/Folders
						["<D-b>"] = require("telescope._extensions.file_browser.actions").toggle_browser,
						["<bs>"] = false, -- unmap <BS> on empty prompt going up; requires lowercase key
					},
				},
			},
		},
	}
end

return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope-file-browser.nvim",
		},
		config = function()
			telescopeConfig()
			require("telescope").load_extension("file_browser")
			require("telescope").load_extension("projects")
		end,
	},
}
