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
			{ "<leader>ot", vim.cmd.TSContextToggle, desc = " Treesitter Context" },
		},
		opts = {
			max_lines = 4,
			multiline_threshold = 1, -- only show 1 line per context
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
			winblend = 10, -- little transparency, hard to see in many themes otherwise
			handlers = {
				cursor = { enable = false },
				marks = { enable = false }, -- FIX mark-related error message
				quickfix = { enable = true, signs = { "⟶", "⇛", "⇛" } },
			},
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
				-- formats virtual text as a bubble
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
		main = "rainbow-delimiters.setup",
		init = function() u.colorschemeMod("RainbowDelimiterRed", { fg = "#7e8a95" }) end,
	},
	{ -- emphasized headers & code blocks in markdown
		"lukas-reineke/headlines.nvim",
		ft = { "markdown", "yaml" },
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			markdown = {
				fat_headlines = false,
				dash_string = "─",
			},
		},
	},
	{ -- color previews & color picker
		"uga-rosa/ccc.nvim",
		keys = {
			{ "<D-p>", vim.cmd.CccPick, desc = " Color Picker" },
			-- INFO textobj is not forward-seeking
			{ "#", "<Plug>(ccc-select-color)", mode = "o", desc = "󱡔 color textobj" },
		},
		ft = { "css", "scss", "sh", "lua" },
		config = function()
			vim.opt.termguicolors = true
			local ccc = require("ccc")
			ccc.setup {
				win_opts = { border = u.borderStyle },
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

			-- extra keybindings (WARN setting via lazy filetype-keys is buggy)
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
				min_width = { 0.4, 72 }, -- 72 = git commit msg length
				mappings = { n = { ["q"] = "Close" } },
			},
			select = {
				backend = { "builtin" },
				trim_prompt = true,
				builtin = {
					mappings = { ["q"] = "Close" },
					show_numbers = false,
					border = u.borderStyle,
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
					local kind = opts.kind
					if not kind then return end

					-- code actions: show at cursor
					if kind == "codeaction" then return { builtin = { relative = "cursor" } } end

					-- complex selectors: use telescope
					if
						kind == "mason.ui.language-filter"
						or kind:find("^tinygit")
						or kind == "snippetList"
					then
						return { backend = "telescope" }
					end
				end,
			},
		},
	},
}
