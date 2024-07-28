local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- fixes scrolloff at end of file
		"Aasim-A/scrollEOF.nvim",
		event = "CursorMoved",
		opts = true,
		keys = {
			{
				"<leader>of",
				function() vim.opt.scrolloff = vim.g.baseScrolloff end,
				desc = "⇓ Fix Scrolloff",
			},
		},
	},
	{ -- indentation guides
		"lukas-reineke/indent-blankline.nvim",
		event = "UIEnter",
		main = "ibl",
		opts = {
			scope = {
				highlight = "Comment",
				show_start = false,
				show_end = false,
			},
			indent = {
				char = { "│", "┊" },
				tab_char = { "│", "┊" },
			},
		},
	},
	{ -- scrollbar with information
		"lewis6991/satellite.nvim",
		event = "VeryLazy",
		init = function() u.colorschemeMod("SatelliteQuickfix", { link = "DiagnosticSignInfo" }) end,
		opts = {
			winblend = 10, -- little transparency, since hard to see in many themes otherwise
			handlers = {
				cursor = { enable = false },
				marks = { enable = false }, -- prevents not creating mark mappings
				quickfix = { enable = true },
			},
		},
	},
	{ -- markdown live-preview
		"MeanderingProgrammer/markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		main = "render-markdown",
		ft = "markdown",
		keys = {
			{
				"<leader>oc",
				function() require("render-markdown").toggle() end,
				ft = "markdown",
				desc = " Markdown Render",
			},
		},
		opts = {
			render_modes = { "n", "c", "i" },
			bullet = {
				icons = { "•", "◦", "▪️", "▫️" },
			},
			pipe_table = { enabled = false }, -- sluggish on bigger files
			latex = { enabled = false }, -- unneeded
			sign = { enabled = false },
			code = { border = "thick" },
			win_options = {
				-- toggling this plugin should also toggle conceallevel
				conceallevel = { default = 0, rendered = 3 },
			},
		},
	},
	{ -- color previews & color picker
		"uga-rosa/ccc.nvim",
		keys = {
			{ "#", vim.cmd.CccPick, desc = " Color Picker" },
		},
		ft = { "css", "scss", "zsh", "lua", "toml" },
		config = function(spec)
			local ccc = require("ccc")

			ccc.setup {
				win_opts = { border = vim.g.borderStyle },
				highlight_mode = "background",
				highlighter = {
					auto_enable = true,
					filetypes = spec.ft, -- uses lazy.nvim's ft spec
					max_byte = 200 * 1024, -- 200kb
					update_insert = false,
				},
				pickers = {
					ccc.picker.hex_long, -- only long hex to not pick issue numbers like #123
					ccc.picker.css_rgb,
					ccc.picker.css_hsl,
					ccc.picker.css_name,
					ccc.picker.ansi_escape({ blue = "#3165ff" }, { meaning1 = "bold" }),
				},
				alpha_show = "hide", -- needed when highlighter.lsp is set to true
				recognize = { output = true }, -- automatically recognize color format under cursor
				inputs = { ccc.input.hsl }, -- always use HSL-logic for input
				outputs = {
					ccc.output.css_hsl,
					ccc.output.css_rgb,
					ccc.output.hex,
				},
				mappings = {
					["<Esc>"] = ccc.mapping.quit,
					["q"] = ccc.mapping.quit,
					["L"] = ccc.mapping.increase10,
					["H"] = ccc.mapping.decrease10,
					["o"] = ccc.mapping.cycle_output_mode, -- = change output format
				},
			}
		end,
	},
	{ -- Better input/selection fields
		"stevearc/dressing.nvim",
		init = function()
			---@diagnostic disable: duplicate-set-field
			vim.ui.select = function(items, opts, on_choice)
				require("lazy").load { plugins = { "dressing.nvim" } }
				return vim.ui.select(items, opts, on_choice)
			end

			---@param opts { prompt?: string, default?: any, completion?: string, highlight?: function }
			---@param on_confirm function ((input|nil) -> ())
			vim.ui.input = function(opts, on_confirm)
				require("lazy").load { plugins = { "dressing.nvim" } }
				return vim.ui.input(opts, on_confirm)
			end
			---@diagnostic enable: duplicate-set-field
		end,
		keys = {
			{ "<Tab>", "j", ft = "DressingSelect" },
			{ "<S-Tab>", "k", ft = "DressingSelect" },
		},
		opts = {
			input = {
				trim_prompt = true,
				border = vim.g.borderStyle,
				relative = "editor",
				prefer_width = 45,
				min_width = 0.4,
				max_width = 0.8,
				mappings = { n = { ["q"] = "Close" } },
			},
			select = {
				trim_prompt = true,
				builtin = {
					mappings = { ["q"] = "Close" },
					show_numbers = false,
					border = vim.g.borderStyle,
					relative = "editor",
					max_width = 80,
					min_width = 20,
					max_height = 12,
					min_height = 3,
				},
				telescope = {
					layout_config = {
						horizontal = { width = { 0.7, max = 75 }, height = 0.6 },
					},
				},
				get_config = function(opts)
					local useBuiltin = { "just-recipes", "codeaction", "rule_selection" }
					if vim.tbl_contains(useBuiltin, opts.kind) then
						return { backend = { "builtin" }, builtin = { relative = "cursor" } }
					end
				end,
			},
		},
	},
}
