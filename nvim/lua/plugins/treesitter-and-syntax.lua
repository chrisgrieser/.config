local textobjMaps = require("config.utils").textobjMaps
--------------------------------------------------------------------------------

local tsConfig = {
	-- easier than keeping track of new parsers, especially the special ones,
	-- which are not auto-installed (luap, luadocs)
	ensure_installed = "all",

	highlight = {
		enable = true,
		disable = { "css" }, -- PENDING https://github.com/tree-sitter/tree-sitter-css/issues/34
	},
	indentation = { enable = true }, -- autoindent with `=`

	--------------------------------------------------------------------------
	-- TREESITTER PLUGINS

	textobjects = {
		move = { -- move to next function
			enable = true,
			set_jumps = true,
			disable = { "markdown", "css", "scss" }, -- so they can be mapped to heading/section navigation
			goto_next_start = { ["<C-j>"] = "@function.outer" },
			goto_previous_start = { ["<C-k>"] = "@function.outer" },
		},
		select = { -- textobj definitions
			enable = true,
			lookahead = true,
			include_surrounding_whitespace = false,
			disable = { "markdown" }, -- so `al` can be remapped to link text object
			keymaps = {
				-- INFO: outer key textobj defined via various textobjs
				["ik"] = { query = "@assignment.lhs", desc = "󱡔 inner key textobj" },
				["a<CR>"] = { query = "@return.outer", desc = "󱡔 outer return textobj" },
				["i<CR>"] = { query = "@return.inner", desc = "󱡔 inner return textobj" },
				["a/"] = { query = "@regex.outer", desc = "󱡔 outer regex textobj" },
				["i/"] = { query = "@regex.inner", desc = "󱡔 inner regex textobj" },
				["aa"] = { query = "@parameter.outer", desc = "󱡔 outer parameter textobj" },
				["ia"] = { query = "@parameter.inner", desc = "󱡔 inner parameter textobj" },

				-- stylua: ignore start
				["iu"] = { query = "@loop.inner", desc = "󱡔 inner loop textobj" }, -- mnemonic: luup
				["au"] = { query = "@loop.outer", desc = "󱡔 outer loop textobj" },
				["a" .. textobjMaps.func] = { query = "@function.outer", desc = "󱡔 outer function textobj" },
				["i" .. textobjMaps.func] = { query = "@function.inner", desc = "󱡔 inner function textobj" },
				["a" .. textobjMaps.cond] = { query = "@conditional.outer", desc = "󱡔 outer cond. textobj" },
				["i" .. textobjMaps.cond] = { query = "@conditional.inner", desc = "󱡔 inner cond. textobj" },
				["a" .. textobjMaps.call] = { query = "@call.outer", desc = "󱡔 outer call textobj" },
				["i" .. textobjMaps.call] = { query = "@call.inner", desc = "󱡔 inner call textobj" },
				-- stylua: ignore end

				-- INFO later remapped to q only in operator pending mode to avoid conflict
				-- @comment.inner not supported yet for most languages
				["&&&"] = { query = "@comment.outer", desc = "which_key_ignore" },
			},
		},
	},
	matchup = {
		enable = true,
		enable_quotes = true,
		disable_virtual_text = true, -- nvim-context-vt is better
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

	-- Syntax Highlighting Plugins
	{ "mityu/vim-applescript", ft = "applescript" },
	{ "hail2u/vim-css3-syntax", ft = "css" }, -- FIX https://github.com/tree-sitter/tree-sitter-css/issues/34
}
