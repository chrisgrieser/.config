return {
	{ -- schemas for json-lsp
		"b0o/SchemaStore.nvim",
		lazy = true, -- will be loaded on jsonls setup
	},
	{ -- breadcrumbs for statusline/winbar
		"SmiteshP/nvim-navic",
		event = "LspAttach",
		config = function()
			require("nvim-navic").setup {
				icons = { Object = "ﴯ " },
				separator = "  ",
				depth_limit = 7,
				depth_limit_indicator = "…",
			}
		end,
	},
	{
		"folke/neodev.nvim", -- lsp for nvim-lua config
		config = function()
			-- INFO this must come before lua LSP setup
			require("neodev").setup {
				library = { plugins = false },
			}
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		cmd = "InsertEnter", -- signatures only displayed in insert mode
		config = function()
			require("lsp_signature").setup {
				floating_window = false,
				hint_prefix = "﬍ ",
				hint_scheme = "NonText", -- highlight group
			}
		end,
	},
	{
		-- INFO only temporarily needed, until https://github.com/neovim/neovim/issues/18086
		"lvimuser/lsp-inlayhints.nvim",
		event = "LspAttach",
		config = function()
			require("lsp-inlayhints").setup {
				inlay_hints = {
					parameter_hints = {
						show = true,
						prefix = " ",
						remove_colon_start = true,
						remove_colon_end = true,
					},
					type_hints = {
						show = true,
						prefix = "   ",
						remove_colon_start = true,
						remove_colon_end = true,
					},
					only_current_line = true,
					highlight = "NonText", -- highlight group
				},
			}
		end,
	},
	{
		"smjonas/inc-rename.nvim",
		event = "LspAttach",
		config = function() require("inc_rename").setup {} end,
	},
}
