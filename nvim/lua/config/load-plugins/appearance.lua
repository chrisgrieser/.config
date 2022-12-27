return {
	{
		"m-demare/hlargs.nvim", -- highlight function args
		event = "VeryLazy",
		config = function() require("hlargs").setup() end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup {
				show_current_context = true,
				use_treesitter = true,
				strict_tabs = false,
				filetype_exclude = {},
			}
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup {
				max_file_length = 10000,
				preview_config = { border = borderStyle },
			}
		end,
	},

	-- scrollbar
	{
		"lewis6991/satellite.nvim",
		event = "VeryLazy",
		config = function()
			require("satellite").setup {
				current_only = true,
				winblend = 30,
				excluded_filetypes = {},
				handlers = {
					marks = { enable = false },
				},
			}
		end,
	},

	-- nicer colorcolumn
	{
		"xiyaowong/virtcolumn.nvim",
		event = "VeryLazy",
		config = function() g.virtcolumn_char = "║" end,
	},

	-- auto-resize splits
	{
		"anuvyklack/windows.nvim",
		dependencies = "anuvyklack/middleclass",
		cmd = {"DiffviewFileHistory", "DiffviewOpen"},
		keys = "<C-w>", -- window split commands
		config = function()
			require("windows").setup {
				autowidth = {
					enable = true,
					winwidth = 0.7, -- active window gets 70% of total width
				},
			}
		end,
	},
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		dependencies = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-omni" }, -- omni for autocompletion in input prompts
		config = function()
			require("dressing").setup {
				input = {
					border = borderStyle,
					relative = "win",
					max_width = 50, -- length git commit msg
					min_width = 50,
					win_options = {
						sidescrolloff = 0,
						winblend = 0,
					},
					insert_only = false, -- enable normal mode
					mappings = {
						n = { ["q"] = "Close" },
					},
				},
				select = {
					backend = { "builtin" }, -- Priority list of preferred vim.select implementations
					trim_prompt = true, -- Trim trailing `:` from prompt
					builtin = {
						border = borderStyle,
						relative = "cursor",
						max_width = 60,
						min_width = 18,
						max_height = 12,
						min_height = 4,
						mappings = {
							["q"] = "Close",
							["Esc"] = "Close",
						},
					},
				},
			}
		end,
	},
}
