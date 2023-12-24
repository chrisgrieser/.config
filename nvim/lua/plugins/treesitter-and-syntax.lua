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
	{ -- FIX https://github.com/tree-sitter/tree-sitter-css/issues/34
		"hail2u/vim-css3-syntax",
		ft = "css",
	},
	{
		"wookayin/semshi", -- maintained fork
		ft = "python",
		build = ":UpdateRemotePlugins", -- don't disable `rplugin` in lazy.nvim for this
		init = function()
			vim.g.python3_host_prog = vim.fn.exepath("python3")
			-- better provided by LSP
			vim.g["semshi#error_sign"] = false
			vim.g["semshi#simplify_markup"] = false
			vim.g["semshi#mark_selected_nodes"] = false
			vim.g["semshi#update_delay_factor"] = 0.001

			vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
				callback = function()
					vim.cmd([[
						highlight! semshiGlobal gui=italic
						highlight! link semshiImported @lsp.type.namespace
						highlight! link semshiParameter @lsp.type.parameter
						highlight! link semshiParameterUnused DiagnosticUnnecessary
						highlight! link semshiBuiltin @function.builtin
						highlight! link semshiAttribute @field
						highlight! link semshiSelf @lsp.type.selfKeyword
						highlight! link semshiUnresolved @lsp.type.unresolvedReference
						highlight! link semshiFree @comment
					]])
				end,
			})
		end,
	},
}
