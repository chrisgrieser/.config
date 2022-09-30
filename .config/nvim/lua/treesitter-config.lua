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
	},

	auto_install = true, -- ensure the above are actually installed

	highlight = {
		-- NOTE: these are the names of the parsers and not the filetype. (for
		-- example if you want to disable highlighting for the `tex` filetype, you
		-- need to include `latex` in this list as this is the name of the parser)
		disable = { "c", "rust" },

		-- Setting this to true will run `:h syntax` and tree-sitter at the same
		-- time. Set this to `true` if you depend on 'syntax' being enabled (like
		-- for indentation). Using this option may slow down your editor, and you
		-- may see some duplicate highlights. Instead of true it can also be a
		-- list of languages
		additional_vim_regex_highlighting = false,
	},
}

