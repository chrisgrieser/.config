local function tsConfig()
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
			"gitcommit",
			"diff",
			"regex",
			"python",
			"lua",
			"toml",
			"vim",
			"yaml",
			"json",
		},
		auto_install = false, -- install missing parsers when entering a buffer

		highlight = {
			enable = true,
			disable = { -- NOTE: these are the names of the parsers and not the filetype
				"css", -- looks weird with css: https://github.com/tree-sitter/tree-sitter-css/issues/34
				"scss",
				"markdown", -- looks worse and enables spellcheck in URLs and Code Blocks 🙈
			},
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				-- set to `false` to disable one of the mappings
				node_incremental = "<CR>",
				node_decremental = "<BS>",
				init_selection = false, -- can init by simply entering visual mode
				scope_incremental = false,
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
				set_jumps = true,
				disable = { "markdown", "css", "scss" }, -- so they can be mapped to heading/section navigation
				goto_next_start = { ["<C-j>"] = "@function.outer" },
				goto_previous_start = { ["<C-k>"] = "@function.outer" },
			},
			select = {
				enable = true,
				lookahead = true,
				disable = { "markdown" }, -- so they can be remapped to link text object
				keymaps = {
					["af"] = "@function.outer", -- [f]unction
					["if"] = "@function.inner",
					["aa"] = "@parameter.outer", -- [a]rgument
					["ia"] = "@parameter.inner",
					["ao"] = "@conditional.outer", -- c[o]nditional (`ac` already = a curly)
					["io"] = "@conditional.inner",
					["il"] = "@call.inner", -- cal[l]
					["al"] = "@call.outer",
					["iL"] = "@loop.inner", -- [L]oop
					["aL"] = "@loop.outer",
					["q"] = "@comment.outer", -- @comment.inner not supported yet for most languages
				},
				include_surrounding_whitespace = false,
			},
		},

		-- TREESITTER PLUGINS
		endwise = { enable = true },
		rainbow = {
			enable = true,
			query = "rainbow-parens",
			strategy = require("ts-rainbow.strategy.global"),
			-- compatibility, since the highlight clearing leaves only hl groups from
			-- the theme, which does not include the rainbow2 hl groups https://github.com/HiPhish/nvim-ts-rainbow2/blob/master/doc/ts-rainbow.txt#L74
			hlgroups = {
				"rainbowcol1",
				"rainbowcol2",
				"rainbowcol3",
				"rainbowcol4",
				"rainbowcol5",
				"rainbowcol6",
				"rainbowcol7",
			},
		},

		refactor = {
			highlight_definitions = {
				enable = true,
				clear_on_cursor_move = true, -- set to false if `updatetime` of ~100ms
			},
			highlight_current_scope = { enable = false },
			smart_rename = {
				enable = true,
				keymaps = {
					-- overwritten by on lsp-attach with LSP's rename, but useful for
					-- filetypes without lsp support
					smart_rename = "<leader>R",
				},
			},
		},
	}

	-- force treesitter to highlight zsh as if it was bash
	vim.api.nvim_create_augroup("zshAsBash", {})
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = "zshAsBash",
		pattern = { "*.sh", "*.zsh", ".zsh*" },
		command = "silent! set filetype=sh",
	})
end

--------------------------------------------------------------------------------

return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = "VimEnter",
		config = tsConfig,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"HiPhish/nvim-ts-rainbow2",
			"RRethy/nvim-treesitter-endwise", -- autopair, but for keywords
		},
		-- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
		build = function() require("nvim-treesitter.install").update { with_sync = true } end,
	},
	{ "mityu/vim-applescript", ft = "applescript" }, -- syntax highlighting
	{ "hail2u/vim-css3-syntax", ft = "css" }, -- better syntax highlighting (until treesitter css looks decent…)
}
