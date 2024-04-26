local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- fixes scrolloff at end of file
		"Aasim-A/scrollEOF.nvim",
		event = "CursorMoved",
		opts = true,
	},
	{ -- context lines
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		keys = {
			{
				"gk",
				function() require("treesitter-context").go_to_context() end,
				desc = " Goto Context",
			},
		},
		opts = {
			max_lines = 4,
			multiline_threshold = 1, -- only show 1 line per context

			-- disable in markdown, PENDING https://github.com/nvim-treesitter/nvim-treesitter-context/issues/289
			on_attach = function()
				vim.defer_fn(function()
					if vim.bo.filetype == "markdown" then return false end
				end, 1)
			end,
		},
		init = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					-- adds grey underline
					local grey = u.getHighlightValue("Comment", "fg")
					vim.api.nvim_set_hl(
						0,
						"TreesitterContextBottom",
						{ special = grey, underline = true }
					)
				end,
			})
		end,
	},
	{ -- indentation guides
		"lukas-reineke/indent-blankline.nvim",
		event = "UIEnter",
		main = "ibl",
		opts = {
			scope = {
				enabled = false, -- using `cool-chunk` instead
				highlight = "Comment",
				show_start = false,
				show_end = false,
				show_exact_scope = true,
			},
			indent = { char = "│", tab_char = "│" },
			exclude = { filetypes = { "undotree" } },
		},
	},
	{
		"Mr-LLLLL/cool-chunk.nvim",
		event = { "CursorHold", "CursorHoldI" },
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			chunk = {
				animate_duration = 150,
				chars = {
					right_arrow = "▷",
					left_arrow = "◁",
					down_arrow = "▽",
				},
				hl_group = {
					chunk = "Comment",
					error = "Error",
				},
				textobject = "<Nop>",
			},
			context = {
				textobject = "<Nop>",
			},
		},
	},
	{ -- scrollbar with information
		"lewis6991/satellite.nvim",
		commit = "5d33376", -- TODO following versions require nvim 0.10
		event = "VeryLazy",
		opts = {
			winblend = 10, -- little transparency, hard to see in many themes otherwise
			handlers = {
				cursor = { enable = false },
				marks = { enable = false }, -- FIX mark-related error message
				quickfix = { enable = true, signs = { "·", ":", "󰇙" } },
			},
		},
	},
	{ -- when searching, search count is shown next to the cursor
		"kevinhwang91/nvim-hlslens",
		-- loaded by snippet in opts-and-autocmds.lua
		init = function()
			-- cannot use my utility, as the value of IncSearch needs to be retrieved dynamically
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					local reversed = u.getHighlightValue("IncSearch", "bg")
					vim.api.nvim_set_hl(0, "HLSearchReversed", { fg = reversed })
				end,
			})
		end,
		opts = {
			nearest_only = true,
			override_lens = function(render, posList, nearest, idx, _)
				-- formats virtual text as a bubble
				local lnum, col = unpack(posList[idx])
				local text = ("%d/%d"):format(idx, #posList)
				local chunks = {
					{ " ", "Padding-Ignore" },
					{ "", "HLSearchReversed" },
					{ text, "HlSearchLensNear" },
					{ "", "HLSearchReversed" },
				}
				render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
			end,
		},
	},
	{ -- rainbow brackets
		"hiphish/rainbow-delimiters.nvim",
		event = "BufReadPost", -- later does not load on first buffer
		dependencies = "nvim-treesitter/nvim-treesitter",
		main = "rainbow-delimiters.setup",
		init = function() u.colorschemeMod("RainbowDelimiterRed", { fg = "#7e8a95" }) end,
	},
	{ -- emphasized headers & code blocks in markdown
		"lukas-reineke/headlines.nvim",
		ft = "markdown",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			markdown = {
				fat_headlines = false,
				bullets = false,
				dash_string = "─",
			},
		},
	},
	{ -- color previews & color picker
		"uga-rosa/ccc.nvim",
		keys = {
			{ "g#", vim.cmd.CccPick, desc = " Color Picker" },
		},
		ft = { "css", "scss", "sh", "lua" },
		config = function()
			vim.opt.termguicolors = true
			local ccc = require("ccc")
			ccc.setup {
				win_opts = { border = vim.g.borderStyle },
				highlighter = {
					auto_enable = true,
					max_byte = 1.5 * 1024 * 1024, -- 1.5 Mb
					lsp = true,
					filetypes = { "css", "scss", "sh", "lua" },
				},
				pickers = {
					ccc.picker.hex,
					ccc.picker.css_rgb,
					ccc.picker.css_hsl,
					ccc.picker.ansi_escape { meaning1 = "bright" },
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
					["o"] = ccc.mapping.toggle_output_mode, -- = convert color
				},
			}
		end,
	},
	{ -- Better input/selection fields
		"stevearc/dressing.nvim",
		init = function()
			-- lazy load triggers
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load { plugins = { "dressing.nvim" } }
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
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
				insert_only = false, -- = enable normal mode
				trim_prompt = true,
				border = vim.g.borderStyle,
				relative = "editor",
				title_pos = "left",
				prefer_width = 73, -- commit width + 1 for padding
				min_width = 0.4,
				max_width = 0.9,
				mappings = { n = { ["q"] = "Close" } },
			},
			select = {
				backend = { "telescope", "builtin" },
				trim_prompt = true,
				builtin = {
					mappings = { ["q"] = "Close" },
					show_numbers = false,
					border = vim.g.borderStyle,
					relative = "editor",
					max_width = 80,
					min_width = 20,
					max_height = 20,
					min_height = 3,
				},
				telescope = {
					layout_config = {
						horizontal = { width = { 0.8, max = 75 }, height = 0.55 },
					},
				},
				get_config = function(opts)
					-- for simple selections, use builtin selector instead of telescope
					if opts.kind == "codeaction" or opts.kind == "rule_selection" then
						return { backend = { "builtin" }, builtin = { relative = "cursor" } }
					elseif opts.kind == "make-selector" or opts.kind == "project-selector" then
						return { backend = { "builtin" } }
					end
				end,
			},
		},
	},
}
