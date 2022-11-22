require("nvim-treesitter.configs").setup {
	ensure_installed = {
		"javascript",
		"typescript",
		"markdown",
		"markdown_inline", -- markdown inline code
		"html",
		"help", -- vim help files
		"css",
		"bash",
		"bibtex",
		"gitignore",
		"regex",
		"python",
		"lua",
		"toml",
		"yaml",
		"json",
		"json5",
		"jsonc",
	},
	auto_install = true, -- install missing parers when entering a buffer

	highlight = {
		enable = true,

		-- NOTE: these are the names of the parsers and not the filetype
		disable = {
			"css", -- looks weird with css: https://github.com/tree-sitter/tree-sitter-css/issues/34
			"markdown", -- looks worse and enables spellcheck in URLs and Code Blocks 🙈
		},

	},

	-- use treesitter for autoindent with `=`
	indentation = {
		enable = true,
		disable = {}, -- NOTE: these are the names of the parsers and not the filetype
	},

	textobjects = {-- textobj plugin
		move = {-- move to next comment / function
			enable = true,
			disable = {"markdown"}, -- so they can be mapped to heading navigation
			set_jumps = true,
			goto_next_start = {
				["<C-j>"] = "@function.outer",
			},
			goto_previous_start = {
				["<C-k>"] = "@function.outer",
			},
		},
		swap = {
			enable = true,
			swap_next = {-- mnemonic: [e]xchange
				["<leader>e"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>E"] = "@parameter.inner",
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
				["aC"] = "@conditional.outer", -- [C]onditional (ac = a curly)
				["iC"] = "@conditional.inner",
				["COM"] = "@comment.outer", -- latter remapped to q, not done directly to avoid conflict with visual mode comments
			},
			-- If you set this to `true` (default is `false`) then any textobject is
			-- extended to include preceding xor succeeding whitespace. Succeeding
			-- whitespace has priority in order to act similarly to eg the built-in
			-- `ap`.
			include_surrounding_whitespace = false,
		},
	},

	rainbow = {-- rainbow plugin
		enable = true,
		disable = {}, -- list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = 2000,
	},

	refactor = {-- refactor plugin
	highlight_definitions = {
		enable = true,
		clear_on_cursor_move = true, -- Set to false if you have an `updatetime` of ~100.
	},
	highlight_current_scope = {enable = false},
	smart_rename = {
		enable = true,
		keymaps = {
			-- overwritten by on lsp-attach with LSP's rename, but useful for
			-- filetypes without proper lsp, e.g., bash
			smart_rename = "<leader>R", 
		},
	},
},
}

--------------------------------------------------------------------------------
-- force treesitter to highlight zsh as if it was bash
augroup("zshAsBash", {})
autocmd("BufWinEnter", {
	group = "zshAsBash",
	pattern = {"*.sh", "*.zsh"},
	command = "silent! set filetype=sh",
})
