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
			height = 0.92,
			width = 0.97,
			preview_cutoff = 30,
			horizontal = { preview_width = 40 },
			vertical = { preview_height = 30 },
		},
	},
	pickers = {
		lsp_references = { prompt_prefix='⬅️', show_line=false, trim_text=true, include_declaration=false },
		lsp_definitions = { prompt_prefix='➡️', show_line=false, trim_text=true },
		lsp_document_symbols = { prompt_prefix='*', show_line=false},
		keymaps = { prompt_prefix='🔘' },
		help_tags = { prompt_prefix=':h' },
		commands = { prompt_prefix=':' },
		oldfiles = { prompt_prefix='🕔' },
		highlights = { prompt_prefix='🎨' },
		marks = { prompt_prefix="'" },
		buffers = {prompt_prefix='📑',ignore_current_buffer = true},
		live_grep = {cwd='%:p:h', disable_coordinates=true, prompt_prefix='🔎'},
		current_buffer_fuzzy_find = { prompt_prefix='🔍' },
		spell_suggest = { prompt_prefix='✏️' },
		colorscheme = { enable_preview = true, prompt_prefix='🎨' },
		find_files = { cwd='%:p:h', prompt_prefix='📂', hidden=true },
		treesitter = { show_line=false, prompt_prefix='🌳' },
	}
}


