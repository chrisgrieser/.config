require('nvim-treesitter.configs').setup {
	ensure_installed = { -- A list of parser names, or "all"
		"javascript",
		"typescript",
		"bash",
		"css",
		"json",
		"jsonc",
		"lua",
		"yaml",
		"markdown",
		"markdown_inline",
		"regex",
		"toml",
	},

	highlight = {
		enable = true,

		-- NOTE: these are the names of the parsers and not the filetype
		disable = {"lua"}, -- lua disable since comments and variables get the same color, at least in the terminal

		-- Setting this to true will run `:h syntax` and tree-sitter at the same
		-- time. Set this to `true` if you depend on 'syntax' being enabled (like
		-- for indentation). Using this option may slow down your editor, and you
		-- may see some duplicate highlights. Instead of true it can also be a
		-- list of languages
		additional_vim_regex_highlighting = false,
	},

	indentation = {
		enable = true,
		disable = {}, -- NOTE: these are the names of the parsers and not the filetype
	},

	rainbow = {
		enable = true,
		disable = {}, -- list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
	}
}

-- https://github.com/nvim-treesitter/nvim-treesitter-context#configuration
require'treesitter-context'.setup{
	enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
	max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
	trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
	min_window_height = 15, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
}

