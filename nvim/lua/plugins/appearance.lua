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
				show_exact_scope = true,
			},
			indent = { char = "│", tab_char = "│" },
		},
	},
	{ -- scrollbar with information
		"lewis6991/satellite.nvim",
		event = "VeryLazy",
		init = function() u.colorschemeMod("SatelliteQuickfix", { link = "DiagnosticSignInfo" }) end,
		opts = {
			zindex = 1, -- below most stuff
			winblend = 10, -- little transparency, hard to see in many themes otherwise
			handlers = {
				cursor = { enable = false },
				marks = { enable = false }, -- prevents not creating mark mappings
				quickfix = { enable = true },
			},
		},
	},
	{ -- emphasized headers & code blocks in markdown
		"lukas-reineke/headlines.nvim",
		ft = { "markdown", "yaml" },
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			markdown = {
				fat_headlines = false,
				bullets = false,
			},
			yaml = { codeblock_highlight = "CodeBlock" },
		},
		config = function(_, opts)
			-- add background to injections, see `ftplugin/yaml/injections.scm`
			-- related BUG https://github.com/lukas-reineke/headlines.nvim/issues/85
			opts.yaml.query = vim.treesitter.query.parse(
				"yaml",
				[[
					(block_mapping_pair
						key: (flow_node) @_run
						(#any-of? @_run "run" "shell_command" "cmd")
						value: (block_node
							(block_scalar) @codeblock
							(#offset! @codeblock 1 1 1 0)))
				]]
			)
			require("headlines").setup(opts)
		end,
	},
	{ -- color previews & color picker
		"uga-rosa/ccc.nvim",
		keys = {
			{ "#", vim.cmd.CccPick, desc = " Color Picker" },
		},
		ft = { "css", "scss", "sh", "zsh", "lua" },
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
					ccc.picker.ansi_escape(),
				},
				alpha_show = "hide", -- needed when highlighter.lsp is set to true
				recognize = { output = true }, -- automatically recognize color format under cursor
				inputs = { ccc.input.hsl },
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
			-- lazy load triggers
			vim.ui.select = function(...) ---@diagnostic disable-line: duplicate-set-field
				require("lazy").load { plugins = { "dressing.nvim" } }
				return vim.ui.select(...)
			end
			vim.ui.input = function(...) ---@diagnostic disable-line: duplicate-set-field
				require("lazy").load { plugins = { "dressing.nvim" } }
				return vim.ui.input(...)
			end
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
