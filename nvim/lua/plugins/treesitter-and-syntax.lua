local u = require("config.utils")
--------------------------------------------------------------------------------

local tsConfig = {
	-- easier than keeping track of new parsers, especially "special parsers",
	-- which are not auto-installed on entering a buffer (e.g., luap, luadocs)
	ensure_installed = "all",

	highlight = {
		enable = true,
		disable = { "css" }, -- PENDING https://github.com/tree-sitter/tree-sitter-css/issues/34
	},
	indent = {
		enable = true,
		disable = {
			"markdown", -- indentation at bullet points is worse
			"lua", -- `o` sometimes with weird indentation
			"javascript", -- `o` sometimes with weird indentation
			"typescript", -- `o` sometimes with weird indentation
			"yaml",
		},
	},

	--------------------------------------------------------------------------
	-- TREESITTER PLUGINS

	textobjects = {
		move = { -- move to next function
			enable = true,
			set_jumps = true,
			disable = { "markdown" }, -- using heading-jumping there
		},
		select = { -- textobj definitions
			enable = true,
			lookahead = true,
			include_surrounding_whitespace = false,
			-- markdown does not know most treesitter objects anyway, so disabling
			-- there to be able to map other textobjs
			disable = { "markdown" },
		},
		lsp_interop = {
			enable = true,
			border = u.borderStyle,
			floating_preview_opts = {},
		},
	},
	matchup = {
		enable = true,
		enable_quotes = true,
		disable_virtual_text = true,
	},
	endwise = { enable = true },
}

--------------------------------------------------------------------------------

return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = tsConfig,
	},

	-- FIX https://github.com/tree-sitter/tree-sitter-css/issues/34
	{ "hail2u/vim-css3-syntax", ft = "css" },
}
