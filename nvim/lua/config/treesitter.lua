require("config/utils")
--------------------------------------------------------------------------------

require("nvim-treesitter.configs").setup {
	ensure_installed = {
		"javascript",
		"typescript",
		"html",
		"help", -- vim help files
		"bash",
		"css",
		"markdown",
		"markdown_inline", -- fenced code blocks
		"bibtex",
		"gitignore",
		"diff",
		"regex",
		"python",
		"lua",
		"toml",
		"vim", -- viml
		"yaml",
		"json",
	},
	auto_install = false, -- install missing parsers when entering a buffer

	highlight = {
		enable = true,
		-- NOTE: these are the names of the parsers and not the filetype
		disable = {
			"css", -- looks weird with css: https://github.com/tree-sitter/tree-sitter-css/issues/34
			"scss",
			"markdown", -- looks worse and enables spellcheck in URLs and Code Blocks 🙈
		},
	},

	-- use treesitter for autoindent with `=`
	indentation = {
		enable = true,
		disable = {},
	},
	textobjects = { -- textobj plugin
		move = { -- move to next comment / function
			enable = true,
			disable = { "markdown" }, -- so they can be mapped to heading navigation
			set_jumps = true,
			goto_next_start = {
				["<C-j>"] = "@function.outer",
			},
			goto_previous_start = {
				["<C-k>"] = "@function.outer",
			},
		},
		select = {
			enable = true,
			disable = { "markdown" }, -- so they can be remapped to link text object
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["aa"] = "@parameter.outer", -- [a]rgument
				["ia"] = "@parameter.inner",
				["ao"] = "@conditional.outer", -- c[o]nditional (`ac` already = a curly)
				["io"] = "@conditional.inner",
				["il"] = "@call.inner", -- cal[l]
				["al"] = "@call.outer",
				["iL"] = "@loop.inner", -- [L]oop
				["aL"] = "@loop.outer",
				["COM"] = "@comment.outer", -- HACK later remapped to q, done indirectly to avoid conflict with visual mode comments
			},
			-- If you set this to `true` (default is `false`) then any textobject is
			-- extended to include preceding xor succeeding whitespace. Succeeding
			-- whitespace has priority in order to act similarly to eg the built-in
			-- `ap`.
			include_surrounding_whitespace = false,
		},
	},

	-----------------------------------------------------------------------------
	-- plugins

	rainbow = { -- rainbow plugin
		enable = true,
		disable = {}, -- list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = 2000,
	},

	matchup = { -- vim-matchup
		enable = true, -- mandatory, false will disable the whole extension
		disable = {}, -- optional, list of language that will be disabled
		disable_virtual_text = false,
	},

	refactor = { -- refactor plugin
		highlight_definitions = {
			enable = true,
			clear_on_cursor_move = true, -- Set to false if you have an `updatetime` of ~100.
		},
		highlight_current_scope = { enable = false },
		smart_rename = {
			enable = true,
			keymaps = {
				-- overwritten by on lsp-attach with LSP's rename, but useful for
				-- filetypes without proper lsp support
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
	pattern = { "*.sh", "*.zsh", ".zsh*" },
	command = "silent! set filetype=sh",
})
