return {
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
				desc = "User: Define `SatelliteQuickfix` hlgroup",
				callback = function()
					vim.api.nvim_set_hl(0, "SatelliteQuickfix", { link = "DiagnosticSignInfo" })
				end,
			})
		end,
		config = function(_, opts)
			require("satellite").setup(opts)
			require("config.functions-in-scrollbar")
		end,
		opts = {
			winblend = 10, -- only little transparency, since hard to see in many themes otherwise
			handlers = {
				cursor = { enable = false },
				marks = { enable = false },
			},
		},
	},
	{ -- markdown live-preview
		"MeanderingProgrammer/render-markdown.nvim",
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
			sign = { enabled = false },
			heading = { icons = {} }, -- disables icons
			bullet = {
				icons = { "▪️", "▫️", "•", "◦" },
			},
			code = {
				border = "thick",
				position = "left",
			},
			link = {
				custom = {
					-- stylua: ignore start
					youtube = { pattern = "youtube.com", icon = " ", highlight = "RenderMarkdownLink" },
					github = { pattern = "github.com", icon = " ", highlight = "RenderMarkdownLink" },
					neovim = { pattern = "neovim.io", icon = " ", highlight = "RenderMarkdownLink" },
					stackoverflow = { pattern = "stackoverflow.com", icon = "󰓌 ", highlight = "RenderMarkdownLink" },
					discord = { pattern = "discord.com", icon = "󰙯 ", highlight = "RenderMarkdownLink" },
					reddit = { pattern = "reddit.com", icon = " ", highlight = "RenderMarkdownLink" },
					-- stylua: ignore end
				},
			},
			win_options = {
				-- this makes it that toggling this plugin also toggles conceallevel
				conceallevel = { default = 0, rendered = 2 },
			},
		},
	},
	{ -- color previews & color picker
		"uga-rosa/ccc.nvim",
		cmd = { "CccPick", "CccConvert" },
		keys = {
			{ "#", vim.cmd.CccPick, desc = " Color Picker" },
			{ "g#", vim.cmd.CccConvert, desc = " Convert to hsl" },
		},
		ft = { "css", "zsh", "lua", "toml" },
		config = function(spec)
			local ccc = require("ccc")
			ccc.setup {
				win_opts = { border = vim.g.borderStyle },
				highlight_mode = "virtual",
				virtual_symbol = " ",
				highlighter = {
					auto_enable = true,
					filetypes = spec.ft, -- uses lazy.nvim's ft spec
				},
				pickers = { -- = what colors are highlighted
					ccc.picker.hex_long, -- only long hex to not pick issue numbers like #123
					ccc.picker.css_rgb,
					ccc.picker.css_hsl,
					ccc.picker.ansi_escape({
						black = "#767676",
						blue = "#3165ff",
						background = "", -- transparent when using `virtual_symbol`
					}, { meaning1 = "bright" }),
				},
				alpha_show = "hide", -- hide by default
				recognize = { output = true }, -- automatically recognize color format under cursor
				inputs = { ccc.input.hsl }, -- always use HSL-logic for input
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
			vim.ui.select = function(items, opts, on_choice)
				require("lazy").load { plugins = { spec.name } }
				return vim.ui.select(items, opts, on_choice)
			end
			vim.ui.input = function(opts, on_choice)
				require("lazy").load { plugins = { spec.name } }
				return vim.ui.input(opts, on_choice)
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
					show_numbers = false,
					border = vim.g.borderStyle,
					relative = "editor",
					max_width = 80,
					min_width = 20,
					max_height = 12,
					min_height = 3,
					mappings = { ["q"] = "Close" },
				},
				telescope = {
					layout_config = {
						horizontal = { width = { 0.7, max = 75 }, height = 0.6 },
					},
				},
				get_config = function(opts)
					local useBuiltin = { "plain", "codeaction", "rule_selection" }
					if vim.tbl_contains(useBuiltin, opts.kind) then
						return {
							backend = { "builtin" },
							builtin = { relative = "cursor" },
						}
					end
				end,
			},
		},
	},
}
