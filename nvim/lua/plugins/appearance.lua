local u = require("config.utils")

--------------------------------------------------------------------------------

return {
	{ -- fix scrollOff at end of file
		"Aasim-A/scrollEOF.nvim",
		event = "WinScrolled",
		opts = true,
	},
	{ -- when searching, search count is shown next to the cursor
		"kevinhwang91/nvim-hlslens",
		lazy = true, -- loaded by my "vim.on_key" function
		opts = { nearest_only = true },
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
			winblend = 60, -- winblend = transparency
			handlers = {
				-- FIX mark-related error message
				marks = { enable = false },
			},
		},
	},
	{ -- UI overhaul
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		event = "VeryLazy",
		init = function()
			-- Open Log & Scroll to most recent message
			vim.keymap.set({ "n", "x", "i" }, "<D-0>", function()
				require("notify").dismiss()
				vim.cmd.Noice("history")
				vim.defer_fn(function() u.normal("G") end, 1)
			end, { desc = "󰎟 Notification Log" })

			-- set some keybindings for the Noice buffer
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "noice",
				callback = function()
					pcall(vim.api.nvim_buf_set_name, 0, "Noice History")
					vim.keymap.set("n", "<D-w>", vim.cmd.bdelete, { buffer = true, desc = " Close" })
					vim.keymap.set("n", "<D-0>", vim.cmd.bdelete, { buffer = true, desc = " Close" })
				end,
			})
		end,
		opts = {
			-- can be used to filter/redirect stuff
			-- https://www.reddit.com/r/neovim/comments/12lf0ke/comment/jg6idvr/
			-- DOCS https://github.com/folke/noice.nvim#-routes
			routes = {
				-- redirect stuff to the more subtle "mini"
				{ filter = { event = "msg_show", find = "B written$" }, view = "mini" },
				-- nvim-early-retirement
				{ filter = { event = "notify", find = "^Auto%-Closing Buffer:" }, view = "mini" },
				-- nvim-treesitter
				{ filter = { event = "msg_show", find = "^%[nvim%-treesitter%]" }, view = "mini" },
				-- Mason
				{ filter = { event = "notify", find = "successfully u?n?installed.$" }, view = "mini" },
				{ filter = { event = "notify", find = "^%[mason%-" }, view = "mini" },
				-- Codeium.nvim
				{ filter = { event = "notify", find = "^Codeium.nvim:" }, view = "mini" },
				{ filter = { event = "notify", find = "downloading server" }, view = "mini" },
				{ filter = { event = "notify", find = "unpacking server" }, view = "mini" },

				-- unneeded info on search patterns
				{ filter = { event = "msg_show", find = "^/." }, skip = true },
				{ filter = { event = "msg_show", find = "^?." }, skip = true },
				{ filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },

				{ filter = { event = "msg_show", min_height = 10 }, view = "split" },
			},
			cmdline = {
				-- classic cmdline at the bottom to not obfuscate the buffer, e.g.
				-- for :substitute or numb.vnim
				view = "cmdline",
				format = {
					search_down = { icon = "  " },
					cmdline = { icon = " " },
					-- syntax highlighting for `:I`, (see config/user-commands.lua)
					inspect = { pattern = "^:I ", icon = " ", ft = "lua" },
				},
			},
			-- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
			view = {
				mini = { timeout = 3000 },
			},

			-- DISABLED, since conflicts with existing plugins I prefer to use
			popupmenu = { backend = "cmp" }, -- replace with nvim-cmp, since more sources
			messages = { view_search = false }, -- replaced by nvim-hlslens
			lsp = {
				progress = { enabled = false }, -- replaced with nvim-dr-lsp, since this one cannot filter null-ls
				signature = { enabled = false }, -- replaced with lsp_signature.nvim

				-- ENABLED features
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				long_message_to_split = true,
				inc_rename = true,
				lsp_doc_border = true,
			},
		},
	},
	{
		"rcarriga/nvim-notify",
		lazy = true, -- loaded by noice
		-- does not play nice with the terminal
		cond = function() return vim.fn.has("gui_running") == 1 end,
		opts = {
			render = "minimal", -- minimal|default|compact
			top_down = false,
			max_height = 20,
			max_width = 50,
			minimum_width = 15,
			level = 0, -- minimum severity level to display (0 = display all)
			timeout = 7500,
			stages = "slide",
			on_open = function(win)
				if not vim.api.nvim_win_is_valid(win) then return end
				vim.api.nvim_win_set_config(win, { border = u.borderStyle })
			end,
		},
		init = function()
			vim.keymap.set("n", "<Esc>", function()
				local clearPending = require("notify").pending() > 10
				require("notify").dismiss { pending = clearPending }
			end, { desc = "󰎟 Clear Notifications" })

			-- copy [l]ast [n]otice
			vim.keymap.set("n", "<leader>ln", function()
				local history = require("notify").history()
				if #history == 0 then
					vim.notify("No Notification in this session.", u.warn)
					return
				end
				local msg = history[#history].message
				vim.fn.setreg("+", msg)
				vim.notify("Last Notification copied.", u.trace)
			end, { desc = "󰎟 Copy Last Notification" })
		end,
	},
	{ -- rainbow brackets
		"https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
		event = "VeryLazy",
		dependencies = "nvim-treesitter/nvim-treesitter",
		init = function()
			-- rainbow brackets without aggressive red
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function() vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#7e8a95" }) end,
			})
		end,
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
		lazy = true, -- loaded by Telescope & Lualine
		opts = {
			override = {
				-- filetypes
				applescript = { icon = "", color = "#7f7f7f", name = "Applescript" },
				bib = { icon = "", color = "#6e9b2a", name = "BibTeX" },
				http = { icon = "󰴚", name = "HTTP request" },
				-- plugins
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
			{ "#", vim.cmd.CccPick, desc = " Color Picker" },
			{ "'", vim.cmd.CccConvert, desc = " Convert Color" }, -- shift-# on German keyboard
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
					ccc.picker.ansi_escape {
						meaning1 = "bright", -- whether the 1 means bright or yellow
					},
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
				backend = { "telescope", "builtin" }, -- Priority list of vim.select implementations
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
				-- code actions use builtin for quicker picking, otherwise use
				-- telescope
				get_config = function(opts)
					if opts.kind == "codeaction" or opts.kind == "simple" then
						return { backend = "builtin" }
					elseif opts.kind == "github_issue" then
						return {
							backend = "telescope",
							telescope = {
								layout_config = {
									horizontal = { width = 0.99, height = 0.6 },
								},
							},
						}
					end
				end,
			},
		},
	},
}
