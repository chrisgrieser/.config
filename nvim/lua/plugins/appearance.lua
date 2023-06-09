local u = require("config.utils")
local colorPickerFts = {
	"css",
	"scss",
	"lua",
	"sh",
	"zsh",
	"bash",
}

--------------------------------------------------------------------------------

return {
	{ -- rainbow brackets
		"HiPhish/nvim-ts-rainbow2",
		event = "BufEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- indentation guides
		"lukas-reineke/indent-blankline.nvim",
		event = "UIEnter",
		opts = {
			use_treesitter = true,
			show_current_context = true, -- = active indent
			context_highlight_list = { "Comment" }, -- give active indent different color
			filetype_exclude = { "undotree", "help", "man", "lspinfo", "" },
		},
	},
	{ -- filetype-icons for Telescope and Lualine
		"nvim-tree/nvim-web-devicons",
		lazy = true, -- loaded by other plugins
		opts = {
			override = {
				-- filetypes
				applescript = { icon = "", color = "#7f7f7f", name = "Applescript" },
				bib = { icon = "", name = "BibTeX" },
				http = { icon = "󰴚", name = "HTTP request" },
				-- plugins
				lazy = { icon = "", name = "Lazy" },
				mason = { icon = "", name = "Mason" },
			},
		},
	},
	{ -- Scrollbar, also shows search matches and gitsigns
		"dstein64/nvim-scrollview",
		dependencies = "neovim/nvim-lspconfig",
		event = "VeryLazy",
		config = function()
			require("scrollview").setup {
				winblend = 40,
				column = 1,
				signs_on_startup = { "conflicts", "search", "diagnostics", "quickfix", "folds" },
			}
			-- add gitsigns https://github.com/dstein64/nvim-scrollview/blob/main/lua/scrollview/contrib/gitsigns.lua
			require("scrollview.contrib.gitsigns").setup()
		end,
	},
	{ -- color previews & color picker
		"uga-rosa/ccc.nvim",
		ft = colorPickerFts,
		config = function()
			vim.opt.termguicolors = true
			local ccc = require("ccc")
			ccc.setup {
				win_opts = { border = u.borderStyle },
				highlighter = {
					auto_enable = true,
					max_byte = 2 * 1024 * 1024, -- 2mb
					lsp = true,
					filetypes = colorPickerFts,
				},
				pickers = {
					ccc.picker.hex,
					ccc.picker.css_rgb,
					ccc.picker.css_hsl,
					ccc.picker.ansi_escape {
						meaning1 = "bright", -- whether the 1 means bright or yellow
					},
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
	{ -- emphasized headers & code blocks
		"lukas-reineke/headlines.nvim",
		ft = "markdown", -- can work in other fts, but I only use it in markdown
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			markdown = { fat_headlines = false },
		},
	},
	{ -- Better input/selection fields
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			input = {
				insert_only = false, -- enable normal mode
				border = u.borderStyle,
				relative = "editor",
				min_width = { 0.5, 60 },
				win_options = { winblend = 0 }, -- weird shining through
			},
			select = {
				backend = { "telescope", "builtin" }, -- Priority list of vim.select implementations
				trim_prompt = true, -- Trim trailing `:` from prompt
				builtin = {
					border = u.borderStyle,
					relative = "cursor",
					max_width = 80,
					min_width = 20,
					max_height = 20,
					min_height = 4,
					win_options = { winblend = 0 }, -- fix weird shining through
				},
				-- code actions use builtin for quicker picking, otherwise use
				-- telescope
				get_config = function(opts)
					if opts.kind == "codeaction" or opts.kind == "simple" then
						return { backend = "builtin" }
					elseif opts.kind == "github_issue" then
						return {
							backend = "telescope",
							telescope = {
								layout_config = {
									horizontal = { width = 0.99, height = 0.6},
								},
							},
						}
					end
				end,
			},
		},
	},
}
