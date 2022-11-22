-- https://github.com/nvim-telescope/telescope.nvim#telescope-setup-structure
--------------------------------------------------------------------------------

require("telescope").setup {
	defaults = {
		selection_caret = "ﰉ ",
		prompt_prefix = "❱ ",
		path_display = {"tail"},
		file_ignore_patterns = {
			"packer_compiled.lua",
			"packer%-snapshot_",
			"%.DS_Store",
			"%.git/",
			"%.spl",
			"%.log",
			"%[No Name%]", -- new files / sometimes folders (netrw)
			"/$", -- ignore folders (netrw)
			"node_modules/",
			"venv/",
			"%.png",
			"%.zip",
			"%.pxd",
			"%.spoon",
			"%.plist", -- Alfred Config Data
			"%.string",
		},
		mappings = {
			i = {
				["<Esc>"] = "close", -- close w/ one esc
				["<D-w>"] = "delete_buffer",
			},
			n = {
				["<Esc>"] = "close",
				["<D-w>"] = "delete_buffer",
			},
		},
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				height = 0.95,
				preview_cutoff = 70,
				width = 0.92,
				preview_width = {0.55, max = 50}
			},
			bottom_pane = {
				height = 10,
				preview_cutoff = 70,
				prompt_position = "bottom",
			},
		},
	},

	pickers = {
		jumplist = {
			prompt_prefix = "ﴰ",
			show_line = false,
			trim_text = true,
			fname_width = 30,
		},
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
		},
		lsp_document_symbols = {
			prompt_prefix = "* ",
			ignore_symbols = {"string", "boolean", "number"},
		},
		lsp_workspace_symbols = {
			prompt_prefix = "** ",
			ignore_symbols = {"string", "boolean", "number"},
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
		keymaps = {prompt_prefix = " "},
		oldfiles = {prompt_prefix = " "},
		highlights = {prompt_prefix = " "},
		git_files = {
			prompt_prefix = " ",
			show_untracked = true,
		},
		git_bcommits = {
			prompt_prefix = " ",
		},
		buffers = {
			prompt_prefix = "﬘ ",
			ignore_current_buffer = true,
			initial_mode = "normal",
			sort_mru = true,
			prompt_title = false,
			results_title = false,
			theme = "cursor",
			layout_config = {cursor = {width = 0.4}},
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
			layout_config = {cursor = {width = 0.2}},
		},
		builtin = {
			prompt_prefix = "B",
			include_extensions = true,
		},
		colorscheme = {
			enable_preview = true,
			prompt_prefix = " ",
			results_title = "",
			layout_strategy = "bottom_pane",
		},
	},
}
