-- vim-pseudo-modeline: buffer_has_colors
local u = require("config.utils")

--------------------------------------------------------------------------------

return {
	{ -- dim unused windows
		"levouh/tint.nvim",
		event = "VeryLazy",
		opts = { tint = 80, saturation = 0.3 },
	},
	{ -- always show matchparens
		"utilyre/sentiment.nvim",
		event = "VeryLazy",
		opts = true,
	},
	{ -- highlight word under cursor & batch renamer
		"nvim-treesitter/nvim-treesitter-refactor",
		event = "BufReadPre",
		dependencies = "nvim-treesitter/nvim-treesitter",
		init = function()
			u.colorschemeMod("TSDefinition", { underdashed = true })
			u.colorschemeMod("TSDefinitionUsage", { underdotted = true })
		end,
	},
	{ -- scrollbar with information
		"lewis6991/satellite.nvim",
		commit = "5d33376", -- TODO following versions require nvim 0.10
		event = "VeryLazy",
		init = function()
			if vim.version().major == 0 and vim.version().minor >= 10 then
				vim.notify("satellite.nvim can now be updated.")
			end
		end,
		opts = {
			winblend = 0, -- no transparency, hard to see in many themes otherwise
			handlers = { marks = { enable = false } }, -- FIX mark-related error message
		},
	},
	{ -- when searching, search count is shown next to the cursor
		"kevinhwang91/nvim-hlslens",
		init = function()
			-- cannot use my utility, as the value of incsearch needs to be retrieved dynamically
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					local reversed = u.getHighlightValue("IncSearch", "bg")
					vim.api.nvim_set_hl(0, "HLSearchReversed", { fg = reversed })
				end,
			})
		end,
		opts = {
			nearest_only = true,
			-- format virtual text
			override_lens = function(render, posList, nearest, idx, _)
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
		"https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
		event = "BufReadPost", -- later does not load on first buffer
		dependencies = "nvim-treesitter/nvim-treesitter",
		-- red too aggressive
		init = function() u.colorschemeMod("RainbowDelimiterRed", { fg = "#7e8a95" }) end,
	},
	{ -- indentation guides
		"lukas-reineke/indent-blankline.nvim",
		event = "UIEnter",
		opts = {
			use_treesitter = true,
			show_current_context = true, -- color active indent differently
			context_highlight_list = { "Comment" }, -- highlight group
			filetype_exclude = { "undotree", "help", "man", "lspinfo", "" },
		},
	},
	{ -- Nerdfont filetype icons
		"nvim-tree/nvim-web-devicons",
		opts = {
			default = true, -- use default icon as fallback
			override = {
				-- filetypes
				applescript = { icon = "", color = "#7f7f7f", name = "Applescript" },
				bib = { icon = "", color = "#6e9b2a", name = "BibTeX" },
				http = { icon = "󰴚", name = "HTTP request" }, -- for rest.nvim
				-- give plugins icons for my status line components
				gitignore = { icon = "", name = "gitignore" },
				ipython = { icon = "󰌠", name = "ipython" },
				checkhealth = { icon = "󰩂", name = ":checkhealth" },
				noice = { icon = "󰎟", name = "noice.nvim" },
				lazy = { icon = "󰒲", name = "lazy.nvim" },
				mason = { icon = "", name = "mason.nvim" },
				octo = { icon = "", name = "octo.nvim" },
				TelescopePrompt = { icon = "", name = "Telescope" },
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
		cmd = { "CccHighlighterEnable" }, -- enable manually via command
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
					max_byte = 2 * 1024 * 1024, -- 2mb
					lsp = true,
					filetypes = { "css", "scss", "sh" },
				},
				pickers = {
					ccc.picker.hex,
					ccc.picker.css_rgb,
					ccc.picker.css_hsl,
					-- whether the 1 means bright or yellow
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
	{ -- :bnext & :bprevious get visual overview of buffers
		"ghillb/cybu.nvim",
		keys = {
			-- not mapping via <Plug>, since that prevents lazyloading
			-- functions names from: https://github.com/ghillb/cybu.nvim/blob/c0866ef6735a85f85d4cf77ed6d9bc92046b5a99/plugin/cybu.lua#L38
			{ "<BS>", function() require("cybu").cycle("next") end, desc = "󰽙 Next Buffer" },
			{ "<S-BS>", function() require("cybu").cycle("prev") end, desc = "󰽙 Previous Buffer" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		opts = {
			display_time = 1000,
			position = {
				anchor = "bottomcenter",
				max_win_height = 12,
				vertical_offset = 3,
			},
			style = {
				border = u.borderStyle,
				padding = 7,
				path = "tail",
				hide_buffer_id = true,
				highlights = {
					current_buffer = "CursorLine",
					adjacent_buffers = "Normal",
				},
			},
			behavior = {
				mode = {
					default = {
						switch = "immediate",
						view = "paging",
					},
				},
			},
		},
	},
	{ -- Better input/selection fields
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		init = function()
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
				insert_only = false, -- enable normal mode
				border = u.borderStyle,
				relative = "editor",
				min_width = { 0.5, 60 },
				win_options = { winblend = 0 }, -- weird shining through
			},
			select = {
				backend = { "builtin" },
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
			},
		},
	},
}
