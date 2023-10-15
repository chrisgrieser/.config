-- vim-pseudo-modeline: buffer_has_colors
local u = require("config.utils")
--------------------------------------------------------------------------------

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
				char = "│", -- spaces
				tab_char = "│", -- tabs
			},
			exclude = { filetypes = { "undotree" } },
		},
	},
	{ -- scrollbar with information
		"lewis6991/satellite.nvim",
		commit = "5d33376", -- TODO following versions require nvim 0.10
		event = "VeryLazy",
		opts = {
			winblend = 0, -- no transparency, hard to see in many themes otherwise
			handlers = { marks = { enable = false } }, -- FIX mark-related error message
		},
	},
	{ -- virtual text context at the end of a scope
		"haringsrob/nvim_context_vt",
		event = "VeryLazy",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			prefix = " 󱞷",
			highlight = "NonText",
			min_rows = 12,
			disable_ft = { "markdown", "yaml", "css" },
		},
	},
	{ -- when searching, search count is shown next to the cursor
		"kevinhwang91/nvim-hlslens",
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
				-- formats virtual text
				local lnum, col = unpack(posList[idx])
				local text = ("%d/%d"):format(idx, #posList)
				local chunks = {
					{ " ", "Ignore" }, -- = padding
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
		init = function() u.colorschemeMod("RainbowDelimiterRed", { fg = "#7e8a95" }) end,
		main = "rainbow-delimiters.setup",
		opts = {
			query = {
				lua = "rainbow-blocks",
			},
		},
	},
	{ -- emphasized undo/redos
		"tzachar/highlight-undo.nvim",
		keys = { "u", "U" },
		opts = {
			duration = 250,
			undo = {
				lhs = "u",
				map = "silent undo",
				opts = { desc = "󰕌 Undo" },
			},
			redo = {
				lhs = "U",
				map = "silent redo",
				opts = { desc = "󰑎 Redo" },
			},
		},
	},
	{ -- color previews & color picker
		"uga-rosa/ccc.nvim",
		init = function()
			-- HACK from the vim docs: https://neovim.io/doc/user/options.html#modeline
			-- setting `# vim-pseudo-modeline: buffer_has_colors` enables the
			-- highlighter. Normally, this would not be possible since modelines
			-- only support options set via `set`.
			vim.api.nvim_create_autocmd("BufReadPost", {
				callback = function()
					local firstline = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
					if vim.endswith(firstline, "vim-pseudo-modeline: buffer_has_colors") then
						vim.cmd.CccHighlighterEnable()
					end
				end,
			})
		end,
		cmd = { "CccHighlighterEnable" },
		keys = {
			{ "g#", vim.cmd.CccPick, desc = " Color Picker" }, -- shift-# on german keyboard
		},
		ft = { "css", "scss", "sh" },
		config = function()
			vim.opt.termguicolors = true
			local ccc = require("ccc")
			ccc.setup {
				win_opts = { border = u.borderStyle },
				highlighter = {
					auto_enable = true,
					max_byte = 1.5 * 1024 * 1024, -- 1.5 Mb
					lsp = true,
					filetypes = { "css", "scss", "sh" },
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

			-- extra keybindings
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "DressingSelect",
				callback = function()
					vim.keymap.set("n", "<Tab>", "j", { buffer = true })
					vim.keymap.set("n", "<S-Tab>", "k", { buffer = true })
				end,
			})
		end,
		opts = {
			input = {
				insert_only = false, -- = enable normal mode
				border = u.borderStyle,
				relative = "editor",
				title_pos = "left",
				min_width = { 0.4, 60 },
				mappings = { n = { ["q"] = "Close" } },
			},
			select = {
				backend = { "builtin" },
				trim_prompt = true,
				builtin = {
					mappings = { ["q"] = "Close" },
					show_numbers = false,
					border = u.borderStyle,
					relative = "cursor",
					max_width = 80,
					min_width = 20,
					max_height = 20,
					min_height = 3,
				},
				telescope = {
					layout_config = {
						horizontal = { width = 0.7, height = 0.55 },
					},
				},
				get_config = function(opts)
					local useTelescope = { "tinygit", "mason" }
					local pluginName = vim.split(opts.kind, "%.")[1]
					if vim.tbl_contains(useTelescope, pluginName) then
						return { backend = "telescope" }
					end
				end,
			},
		},
	},
}
