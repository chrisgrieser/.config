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
		init = function()
			vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
				callback = function()
					vim.api.nvim_set_hl(0, "SatelliteQuickfix", { link = "DiagnosticSignInfo" })
				end,
			})
		end,
		opts = {
			winblend = 10, -- little transparency, since hard to see in many themes otherwise
			handlers = {
				cursor = { enable = false },
				marks = { enable = false }, -- prevents buggy mark mappings
				quickfix = { enable = true },
			},
		},
	},
	{ -- markdown live-preview
		"MeanderingProgrammer/render-markdown.nvim",
		-- alternative: markview.nvim (similar featureset, bit buggy though)
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
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
			render_modes = { "n", "c", "i", "v", "V" },
			bullet = {
				icons = { "▪️", "▫️", "•", "◦" },
			},
			heading = {
				icons = {}, -- disables icons
			},
			code = {
				border = "thick",
				position = "left",
			},
			sign = { enabled = false },
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
		ft = { "css", "zsh", "lua", "toml" },
		config = function(spec)
			local ccc = require("ccc")
			ccc.setup {
				win_opts = { border = vim.g.borderStyle },
				highlight_mode = "background",
				highlighter = {
					auto_enable = true,
					filetypes = spec.ft, -- uses lazy.nvim's ft spec
					max_byte = 100 * 1024, -- 100kb
					update_insert = false,
				},
				pickers = {
					ccc.picker.hex_long, -- only long hex to not pick issue numbers like #123
					ccc.picker.css_rgb,
					ccc.picker.css_hsl,
					ccc.picker.css_name,
					ccc.picker.ansi_escape(
						{ black = "#767676", blue = "#3165ff" }, -- higher contrast
						{ meaning1 = "bold" }
					),
				},
				alpha_show = "hide", -- hide by default
				recognize = { output = true }, -- automatically recognize color format under cursor
				inputs = { ccc.input.hsl }, -- always use HSL-logic for input
				outputs = {
					ccc.output.css_hsl,
					ccc.output.css_rgb,
					ccc.output.hex,
				},
				disable_default_mappings = true,
				mappings = {
					["<CR>"] = ccc.mapping.complete,
					["<Esc>"] = ccc.mapping.quit,
					["q"] = ccc.mapping.quit,
					["l"] = ccc.mapping.increase1,
					["h"] = ccc.mapping.decrease1,
					["L"] = ccc.mapping.increase10,
					["H"] = ccc.mapping.decrease10,
					["o"] = ccc.mapping.cycle_output_mode,
					["a"] = ccc.mapping.toggle_alpha,
				},
			}
		end,
	},
	{ -- Better input/selection fields
		"stevearc/dressing.nvim",
		init = function(spec)
			---@diagnostic disable: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load { plugins = { spec.name } }
				return vim.ui.select(...)
			end

			vim.ui.input = function(...)
				require("lazy").load { plugins = { spec.name } }
				return vim.ui.input(...)
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
					local useBuiltin = { "plain", "codeaction", "rule_selection" }
					if vim.tbl_contains(useBuiltin, opts.kind) then
						return { backend = { "builtin" }, builtin = { relative = "cursor" } }
					end
				end,
			},
		},
	},
}
