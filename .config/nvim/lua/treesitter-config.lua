require('nvim-treesitter.configs').setup {
	ensure_installed = {
		"javascript",
		"typescript",
		"markdown",
		"markdown_inline",
		"html",
		"css",
		"scss",
		"bash",
		"bibtex",
		"gitignore",
		"lua",
		"regex",
		"python",
		"toml",
		"yaml",
		"json",
		"json5",
		"jsonc",
	},

	auto_install = true,	-- when entering a buffer

	highlight = {
		enable = true,

		-- NOTE: these are the names of the parsers and not the filetype
		disable = {},

		-- Setting this to true will run `syntax` and tree-sitter at the same
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

	textobjects = { -- textobj plugin
		move = { -- move to next comment / function
			enable = true,
			set_jumps = true,
			goto_next_start = {
				["gq"] = "@comment.outer",
				["<C-j>"] = "@function.outer",
			},
			goto_previous_start = {
				["gQ"] = "@comment.outer",
				["<C-k>"] = "@function.outer",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>S"] = "@parameter.inner",
			},
		},
		select = {
			enable = true,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["aa"] = "@parameter.outer", -- [a]rgument
				["ia"] = "@parameter.inner",
			},
			-- If you set this to `true` (default is `false`) then any textobject is
			-- extended to include preceding xor succeeding whitespace. Succeeding
			-- whitespace has priority in order to act similarly to eg the built-in
			-- `ap`.
			include_surrounding_whitespace = false,
		},
	},
	rainbow = { -- rainbow plugin
		enable = true,
		disable = {}, -- list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = 2000,
	}
}

require'treesitter-context'.setup{
	enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
	max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
	trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
	min_window_height = 20, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
}

