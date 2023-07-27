-- INFO
-- scrollbar plugins tend to be quite buggy all. Using this file to manage
-- multiple of them at the same time for now
--------------------------------------------------------------------------------

return {
	{
		"kevinhwang91/nvim-hlslens",
		enabled = false,
		keys = {
			{ "n", "n<Cmd>lua require('hlslens').start()<CR>", silent = true },
			{ "N", "N<Cmd>lua require('hlslens').start()<CR>", silent = true },
		},
		opts = {},
	},
	{ -- search indicators requires nvim-hlslens as dependency
		"petertriho/nvim-scrollbar",
		event = "VeryLazy",
		cond = false,
		opts = {
			handle = {
				highlight = "ScrollView",
				blend = 60, -- 0 (opaque) - 100 (transparent)
			},
			marks = {
				GitChange = { text = "│" },
				GitAdd = { text = "│" },
			},
			handlers = {
				cursor = false,
				diagnostic = true,
				gitsigns = true,
				handle = true,
				search = false, -- Requires hlslens
			},
		},
	},
	{
		"lewis6991/satellite.nvim",
		cond = true,
		commit = "5d33376", -- TODO following versions require nvim 0.10
		event = "VeryLazy",
		init = function()
			if vim.version().major == 0 and vim.version().minor >= 10 then
				vim.notify("satellite.nvim can now be updated.")
			end
		end,
		opts = {
			winblend = 60, -- winblend = transparency
			handlers = {
				-- FIX displaying marks creates autocmd-mapping of things with m,
				-- making m-bindings infeasable
				marks = { enable = false },
			},
		},
	},
	{ -- INFO buggy and therefore not using rn
		"dstein64/nvim-scrollview",
		enabled = false,
		event = "VeryLazy",
		dependencies = "neovim/nvim-lspconfig",
		config = function()
			require("scrollview").setup {
				winblend = 40,
				column = 1,
				signs_on_startup = { "conflicts", "search", "diagnostics", "quickfix", "folds" },
				refresh_mapping_desc = "which_key_ignore",
				quickfix_symbol = "󰉀 ",
				folds_symbol = " ",
				search_symbol = { "⠂", "⠅", "⠇", "⠗", "⠟", "⠿" },
			}
			-- add gitsigns https://github.com/dstein64/nvim-scrollview/blob/main/lua/scrollview/contrib/gitsigns.lua
			require("scrollview.contrib.gitsigns").setup()
		end,
	},
}
