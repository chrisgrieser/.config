
local colorPickerFts = {
	"css",
	"scss",
	"lua",
	"sh",
	"bash",
	"toml",
	"yaml",
}

--------------------------------------------------------------------------------

return {

	{ -- highlight function args
		"m-demare/hlargs.nvim",
		event = "VeryLazy",
		config = function() require("hlargs").setup() end,
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- rainbow brackets
		"HiPhish/nvim-ts-rainbow2",
		event = "BufEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- indentation guides
		"lukas-reineke/indent-blankline.nvim",
		event = "UIEnter",
		config = function()
			require("indent_blankline").setup {
				show_current_context = true, -- = active indent
				-- context_char = "┃" -- thicker line for active indent
				use_treesitter = true,
				filetype_exclude = { "undotree", "help", "man", "lspinfo", "" },
			}
		end,
	},
	{ -- matchparen but highlight outside parens as well
		"utilyre/sentiment.nvim",
		event = "VeryLazy",
		config = function()
			-- limit search for matches to window height
			require("sentiment").setup { limit = vim.fn.winheight(0) }
		end,
	},
	{ -- filetype-icons for Telescope and Lualine
		"nvim-tree/nvim-web-devicons",
		lazy = true, -- loaded by other plugins
		config = function()
			require("nvim-web-devicons").setup {
				override = {
					applescript = {
						icon = "",
						color = "#7f7f7f",
						name = "Applescript",
					},
				},
			}
		end,
	},
	{ -- Scrollbar, also shows search matches and git signs
		"lewis6991/satellite.nvim",
		event = "VeryLazy",
		config = function()
			require("satellite").setup {
				winblend = 60, -- winblend = transparency
				handlers = {
					-- FIX displaying marks creates autocmd-mapping of things with m,
					-- making m-bindings infeasable
					marks = { enable = false },
				},
			}
		end,
	},
	{ -- color previews & color picker
		"uga-rosa/ccc.nvim",
		ft = colorPickerFts,
		config = function()
			vim.opt.termguicolors = true 
			local ccc = require("ccc")
			ccc.setup {
				win_opts = { border = BorderStyle },
				highlighter = {
					auto_enable = true,
					max_byte = 2 * 1024 * 1024, -- 2mb
					lsp = true,
					filetypes = colorPickerFts,
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
					["L"] = ccc.mapping.increase10,
					["H"] = ccc.mapping.decrease10,
				},
			}
		end,
	},
	{ -- Better input/selection fields
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		config = function()
			local gitCommitMsgLength = 50 -- make dressing as long as git commit messages
			require("dressing").setup {
				input = {
					insert_only = false, -- enable normal mode
					border = BorderStyle,
					relative = "win",
					max_width = gitCommitMsgLength,
					min_width = gitCommitMsgLength,
					win_options = {
						sidescrolloff = 0,
						winblend = 1,
					},
				},
				select = {
					backend = { "builtin", "telescope" }, -- Priority list of vim.select implementations
					trim_prompt = true, -- Trim trailing `:` from prompt
					builtin = {
						border = BorderStyle,
						relative = "cursor",
						max_width = 80,
						min_width = 20,
						max_height = 20,
						min_height = 4,
						win_options = { winblend = 1 },
					},
				},
			}
		end,
	},
}
