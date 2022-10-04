-- https://github.com/nvim-telescope/telescope.nvim#telescope-setup-structure

require("telescope").setup {
	defaults = {
		selection_caret = "⟐ ",
		prompt_prefix = "❱ ",
		path_display = { "tail" },
		file_ignore_patterns = { "packer_compiled.lua", ".DS_Store", ".git/", ".spl" },
		mappings = {
			i = {
				["<Esc>"] = require('telescope.actions').close, -- close w/ one esc
				["?"] = "which_key",
			},
		},
		layout_strategy = 'flex',
      layout_config = {
			height = 0.95,
			width = 0.99,
			preview_cutoff = 30,
			horizontal = { preview_width = 40 },
			vertical = { preview_height = 30 },
		},
	},
	pickers = {
		keymaps = { prompt_prefix='N' },
		help_tags = { prompt_prefix=':h' },
		commands = { prompt_prefix=':' },
		oldfiles = { prompt_prefix='🕔' },
		buffers = {prompt_prefix='📑',ignore_current_buffer = true},
		live_grep = {cwd='%:p:h', disable_coordinates=true, prompt_prefix='🔎'},
		current_buffer_fuzzy_find = { prompt_prefix='🔍' },
		spell_suggest = { prompt_prefix='✏️' },
		colorscheme = { enable_preview = true, prompt_prefix='🎨' },
		find_files = { cwd='%:p:h', prompt_prefix='📂', hidden=true },
		treesitter = { show_line=false, prompt_prefix='🌳' },
	}
}


