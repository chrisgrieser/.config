return {

	{ -- highlight function args
		"m-demare/hlargs.nvim",
		event = "VeryLazy",
		config = function() require("hlargs").setup() end,
	},
	{ -- indentation guides
		"lukas-reineke/indent-blankline.nvim",
		event = "VimEnter", 
		config = function()
			require("indent_blankline").setup {
				show_current_context = true, -- = active indent
				use_treesitter = true,
				filetype_exclude = {"undotree", "help", "man", "lspinfo", ""}
			}
		end,
	},
	{ -- git gutter + hunk textobj
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup {
				max_file_length = 10000,
				preview_config = { border = BorderStyle },
			}
		end,
	},
	{
		"lewis6991/satellite.nvim",
		event = "VeryLazy",
		config = function()
			require("satellite").setup {
				winblend = 60, -- winblend = transparency
				handlers = {
					-- displaying marks creates autocmd-mapping of things with m,
					-- making m-bindings infeasable
					marks = { enable = false },
				},
			}
		end,
	},

	-- deactivated due to `gm` column
	-- { -- nicer colorcolumn
	-- 	"xiyaowong/virtcolumn.nvim",
	-- 	event = "VeryLazy",
	-- 	init = function() vim.g.virtcolumn_char = "║" end,
	-- },

	{ -- color previews & color utilities
		"uga-rosa/ccc.nvim",
		event = "BufEnter", -- cannot use VeryLazy, since the first buffer entered would not get highlights
		cond = vim.g.neovide, -- only load in GUI
		config = function()
			local ccc = require("ccc")
			vim.opt.termguicolors = true -- required for color previewing, but also messes up look in the terminal
			ccc.setup {
				win_opts = { border = BorderStyle },
				highlighter = {
					auto_enable = true,
					max_byte = 2 * 1024 * 1024, -- 2mb
					lsp = true,
					-- ignoring certain filetypes a bit buggy, therefore whitelisting instead
					filetypes = { "css", "scss", "lua", "sh", "bash", "toml", "yaml", "json", "conf" },
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
		end,
	},
	-- Better input fields
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		config = function()
			local gitCommitMsgLength = 50
			require("dressing").setup {
				input = {
					border = BorderStyle,
					relative = "win",
					max_width = gitCommitMsgLength,
					min_width = gitCommitMsgLength,
					win_options = {
						sidescrolloff = 0,
						winblend = 0,
					},
					insert_only = false, -- enable normal mode
				},
				select = {
					backend = { "builtin" }, -- Priority list of preferred vim.select implementations
					trim_prompt = true, -- Trim trailing `:` from prompt
					builtin = {
						border = BorderStyle,
						relative = "cursor",
						max_width = 80,
						min_width = 20,
						max_height = 15,
						min_height = 4,
						win_options = { winblend = 0 },
					},
				},
			}
		end,
	},
}
