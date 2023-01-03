require("config.utils")
local actions = require("telescope.actions")
--------------------------------------------------------------------------------

local maps = {
	["<Esc>"] = "close",
	["<D-w>"] = "delete_buffer",
	["<S-Down>"] = "preview_scrolling_down",
	["<S-Up>"] = "preview_scrolling_up",
	["<C-h>"] = "cycle_history_prev",
	["<C-l>"] = "cycle_history_next",
	["<Up>"] = "move_selection_previous",
	["<Down>"] = "move_selection_next",
	["^"] = "smart_send_to_qflist", -- sends selected, or if none selected, sends all
	["<Tab>"] = function(prompt) -- multi-select
		actions.toggle_selection(prompt)
		actions.move_selection_next(prompt)
	end,
}

require("telescope").setup {
	defaults = {
		selection_caret = "ﰉ ",
		prompt_prefix = "❱ ",
		multi_icon = "洛",
		path_display = { "tail" },
		history = { path = vimDataDir .. "telescope_history" }, -- sync the history
		file_ignore_patterns = {
			"%.DS_Store", -- macOS system file
			"%.git/",
			"%.git$", -- submodules
			"node_modules/", -- node
			"venv/", -- python
			"lib/", -- python
			"%.spl", -- vim spell files
			"%.add", -- vim spell files
			"%.app/", -- internals of mac apps
			"%.ttf", -- fonts
			"%.pxd", -- Pixelmator
			"%.spoon", -- Hammerspoon
			"%.plist", -- Alfred
			"%.data", -- Alfred
			"%.zcomp", -- zsh completion data
			"%.string",
			"%.log",
			"%.png",
			"%.icns",
			"%.zip",
		},
		mappings = { 
			i = maps,
			n = maps,
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
				height = 0.9,
				preview_cutoff = 70,
				width = 0.9,
				preview_width = { 0.55, min = 30 },
			},
			cursor = {
				preview_cutoff = 9001, -- never use preview here
			},
			bottom_pane = {
				height = 8,
				preview_cutoff = 70,
				prompt_position = "bottom",
			},
		},
	},

	pickers = {
		lsp_references = {
			prompt_prefix = "⬅️",
			show_line = false,
			trim_text = true,
			include_declaration = false,
			initial_mode = "normal",
		},
		lsp_definitions = {
			prompt_prefix = "➡️",
			show_line = false,
			trim_text = true,
			initial_mode = "normal",
			theme = "cursor",
			layout_config = {
				cursor = {
					width = 0.7,
					preview_cutoff = 30,
					preview_width = { 0.55, max = 45 },
				},
			},
		},
		lsp_document_symbols = {
			prompt_prefix = "* ",
			ignore_symbols = { "boolean", "number" }, -- markdown headings are symbol-type "string"
			fname_width = 17,
		},
		lsp_workspace_symbols = {
			prompt_prefix = "W* ",
			ignore_symbols = { "string", "boolean", "number" },
			fname_width = 17,
		},
		treesitter = {
			prompt_prefix = " ",
			show_line = false,
		},
		find_files = {
			cwd = "%:p:h",
			prompt_prefix = " ",
			hidden = true,
			follow = true,
		},
		keymaps = { prompt_prefix = "  ", modes = { "n", "i", "c", "x", "o", "t" } },
		oldfiles = { prompt_prefix = " " },
		highlights = { prompt_prefix = " " },
		git_files = {
			prompt_prefix = " ",
			show_untracked = true,
		},
		buffers = {
			prompt_prefix = "﬘ ",
			ignore_current_buffer = true,
			initial_mode = "normal",
			sort_mru = true,
			prompt_title = false,
			results_title = false,
			theme = "cursor",
			layout_config = { cursor = { width = 0.4 } },
		},
		quickfix = {
			-- layout_config = { preview_cutoff = 9001 },
			trim_text = true,
			show_line = true,
		},
		live_grep = {
			cwd = "%:p:h",
			disable_coordinates = true,
			prompt_title = "Search in Folder",
			prompt_prefix = " ",
		},
		loclist = {
			trim_text = true,
			prompt_prefix = " ",
		},
		spell_suggest = {
			initial_mode = "normal",
			prompt_prefix = "暈",
			theme = "cursor",
			layout_config = { cursor = { width = 0.25 } },
		},
		colorscheme = {
			enable_preview = true,
			prompt_prefix = " ",
			results_title = false,
			layout_strategy = "bottom_pane",
		},
	},
	-- https://github.com/debugloop/telescope-undo.nvim#configuration
	extensions = {
		undo = {
			diff_context_lines = opt.scrolloff:get() - 2,
			entry_format = "#$ID/$STAT/$TIME",
			layout_config = { preview_width = 0.7 },
			prompt_prefix = "",
			initial_mode = "normal",
		},
	},
}

require("telescope").load_extension("undo")
