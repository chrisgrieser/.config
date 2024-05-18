local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- fixes scrolloff at end of file
		"Aasim-A/scrollEOF.nvim",
		event = "CursorMoved",
		opts = true,
		keys = {
			{ "<leader>of", function() vim.opt.scrolloff = 13 end, desc = "⇓ Fix Scrolloff" },
		},
	},
	-- PENDING https://github.com/nvimdev/indentmini.nvim/issues/15
	-- {
	-- 	"nvimdev/indentmini.nvim",
	-- 	lazy = false,
	-- 	init = function()
	-- 		vim.api.nvim_create_autocmd({"ColorScheme", "VimEnter"}, {
	-- 			callback = function()
	-- 				vim.api.nvim_set_hl(0, "IndentLine", { link = "NonText" })
	-- 				vim.api.nvim_set_hl(0, "IndentLineCurrent", { link = "Comment" })
	-- 			end,
	-- 		})
	-- 	end,
	-- 	opts = {},
	-- },
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
		opts = {
			winblend = 10, -- little transparency, hard to see in many themes otherwise
			handlers = {
				cursor = { enable = false },
				marks = { enable = false }, -- do not create mark mappings
				quickfix = { enable = true },
			},
		},
	},
	{ -- when searching, search count is shown next to the cursor
		"kevinhwang91/nvim-hlslens",
		-- loaded by snippet in opts-and-autocmds.lua
		init = function()
			-- cannot use my utility, as the value of IncSearch needs to be retrieved dynamically
			vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
				callback = function()
					local bg = u.getHighlightValue("IncSearch", "bg")
					vim.api.nvim_set_hl(0, "HLSearchReversed", { fg = bg })
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
	{ -- emphasized headers & code blocks in markdown
		"lukas-reineke/headlines.nvim",
		ft = { "markdown", "yaml" },
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			markdown = {
				fat_headlines = false,
				bullets = false,
				dash_string = "─",
			},
			yaml = {
				codeblock_highlight = "CodeBlock",
			},
		},
		config = function(_, opts)
			-- add background to injections, see `ftplugn/yaml/injections.scm`
			opts.yaml.query = vim.treesitter.query.parse(
				"yaml",
				[[
					(block_mapping_pair
					key: (flow_node) @_run (#any-of? @_run "run" "shell_command")
					value: (block_node
								(block_scalar) @codeblock
								(#offset! @codeblock 1 0 1 0)))
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
		ft = { "css", "scss", "sh", "lua" },
		config = function()
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
