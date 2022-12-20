require("config/utils")
--------------------------------------------------------------------------------

local maps = {
	["<Esc>"] = "close",
	["<D-w>"] = "delete_buffer",
	["?"] = "which_key",
	["<S-Down>"] = "preview_scrolling_down",
	["<S-Up>"] = "preview_scrolling_up",
}

require("telescope").setup {
	defaults = {
		selection_caret = "ﰉ ",
		prompt_prefix = "❱ ",
		path_display = { "tail" },
		file_ignore_patterns = {
			"%.DS_Store", -- Mac system file
			"%.git/",
			"%.git", -- submodules
			"%.spl", -- vim spell files
			"%.log",
			"%[No Name%]", -- new files / sometimes folders (netrw)
			"/$", -- ignore folders (netrw)
			"node_modules/", -- js
			"venv/", -- python
			"lib/", -- python
			"%.png",
			"%.zip",
			"%.pxd", -- Pixelmator images
			"%.spoon", -- Hammerspoon
			"%.plist", -- Alfred Config Data
			"%.string",
		},
		mappings = {
			i = maps,
			n = maps,
		},
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				height = 0.95,
				preview_cutoff = 70,
				width = 0.95,
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
			ignore_symbols = { "string", "boolean", "number" },
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
		keymaps = { prompt_prefix = " " },
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
		live_grep = {
			cwd = "%:p:h",
			disable_coordinates = true,
			prompt_title = "Search in Folder",
			prompt_prefix = " ",
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
	extensions = {
		undo = {
			layout_config = {
				preview_width = 0.65,
			},
			prompt_prefix = "",
			initial_mode = "normal",
			side_by_side = false,
		},
	},
}
