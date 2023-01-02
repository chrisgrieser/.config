return {

	"nvim-lualine/lualine.nvim", -- status line
	"rcarriga/nvim-notify", -- notifications

	{ -- highlight function args
		"m-demare/hlargs.nvim",
		event = "VeryLazy",
		config = function() require("hlargs").setup() end,
	},
	{ -- indentation guides
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup {
				show_current_context = true, -- active indent
				use_treesitter = true,
			}
		end,
	},
	{ -- git gutter + hunk textobj
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup {
				max_file_length = 10000,
				preview_config = { border = borderStyle },
			}
		end,
	},
	{ -- scrollbar
		"dstein64/nvim-scrollview",
		event = "VeryLazy",
		config = function()
			require("scrollview").setup {
				current_only = true,
				winblend = 85,
				base = "right",
				column = 1,
			}
		end,
	},
	{ -- nicer colorcolumn
		"xiyaowong/virtcolumn.nvim",
		init = function() vim.g.virtcolumn_char = "║" end,
		event = "VeryLazy",
	},
	{ -- color previews & color utilities
		"uga-rosa/ccc.nvim",
		event = "VeryLazy",
		cond = function() return vim.g.neovide or vim.g.goneovim end, -- only load in GUI
		config = function()
			local ccc = require("ccc")
			vim.opt.termguicolors = true -- required for color previewing, but also messes up look in the terminal
			ccc.setup {
				win_opts = { border = borderStyle },
				highlighter = {
					auto_enable = true,
					max_byte = 2 * 1024 * 1024, -- 2mb
					lsp = true,
					excludes = { "lazy", "gitcommit", "NeogitCommitMessage" },
				},
				alpha_show = "hide", -- needed when highlighter.lsp is set to true
				recognize = { output = true }, -- automatically recognize color format under cursor
				inputs = { ccc.input.hsl },
				outputs = {
					ccc.output.css_hsl,
					ccc.output.css_rgb,
					ccc.output.hex,
				},
				convert = {
					{ ccc.picker.hex, ccc.output.css_hsl },
					{ ccc.picker.css_rgb, ccc.output.css_hsl },
					{ ccc.picker.css_hsl, ccc.output.hex },
				},
				mappings = {
					["<Esc>"] = ccc.mapping.quit,
					["q"] = ccc.mapping.quit,
					["L"] = ccc.mapping.increase5,
					["H"] = ccc.mapping.decrease5,
				},
			}
			cmd.CccHighlighterEnable() -- initialize once for the buffer where it's loaded
		end,
	},
	{ -- auto-resize splits
		"anuvyklack/windows.nvim",
		dependencies = "anuvyklack/middleclass",
		event = "VeryLazy", -- loading on <C-w> does not seem to work
		cmd = { "DiffviewFileHistory", "DiffviewOpen" },
		config = function()
			require("windows").setup {
				autowidth = {
					enable = true,
					winwidth = 0.7, -- active window gets 70% of total width
				},
			}
		end,
	},
	{ -- Better input fields
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		config = function()
			local gitCommitMsgLength = 50
			require("dressing").setup {
				input = {
					border = borderStyle,
					relative = "win",
					max_width = gitCommitMsgLength,
					min_width = gitCommitMsgLength,
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
