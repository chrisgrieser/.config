local tsConfig = {
	-- easier than keeping track of new "special parsers", which are not
	-- auto-installed on entering a buffer (e.g., regex, luadocs, comments)
	ensure_installed = "all",

	highlight = {
		enable = true,
		disable = { "css" }, -- PENDING https://github.com/tree-sitter/tree-sitter-css/issues/34
	},
	indent = {
		enable = true,
		disable = {
			"markdown", -- indentation at bullet points is worse
			-- `o` sometimes with weird indentation
			"lua",
			"javascript",
			"typescript",
			"yaml",
		},
	},

	--------------------------------------------------------------------------
	-- TREESITTER PLUGINS
	matchup = {
		enable = true,
		enable_quotes = true,
		disable_virtual_text = false,
	},

	endwise = { enable = true },

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
			border = vim.g.myBorderStyle,
			floating_preview_opts = {},
		},
	},
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
	{ -- CSS Highlighting FIX https://github.com/tree-sitter/tree-sitter-css/issues/34
		"hail2u/vim-css3-syntax",
		ft = "css",
	},
	{ -- Python Highlighting
		"wookayin/semshi", -- maintained fork
		ft = "python",
		build = ":UpdateRemotePlugins", -- don't disable `rplugin` in lazy.nvim for this
		init = function()
			-- use `pynvim` installed with mason
			-- (not using `require("mason-registry")` to avoid loading mason)
			-- vim.g.python3_host_prog = vim.fn.stdpath("data")
			-- 	.. "/mason/packages/pynvim/venv/bin/python3"

			-- better provided by LSP
			vim.g["semshi#error_sign"] = false
			vim.g["semshi#simplify_markup"] = false
			vim.g["semshi#mark_selected_nodes"] = false
			vim.g["semshi#update_delay_factor"] = 0.001

			vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
				callback = function()
					local function linkHl(from, to) vim.api.nvim_set_hl(0, from, { link = to }) end
					linkHl("semshiGlobal", "Italic")
					linkHl("semshiImported", "@lsp.type.namespace")
					linkHl("semshiParameter", "@lsp.type.parameter")
					linkHl("semshiParameterUnused", "DiagnosticUnnecessary")
					linkHl("semshiBuiltin", "@function.builtin")
					linkHl("semshiAttribute", "@field")
					linkHl("semshiSelf", "@lsp.type.selfKeyword")
					linkHl("semshiUnresolved", "DiagnosticUnnecessary")
					linkHl("semshiFree", "NonText")
				end,
			})
		end,
	},
}
