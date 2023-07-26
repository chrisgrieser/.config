local u = require("config.utils")
local colorPickerFts = { "css", "scss", "lua", "sh", "zsh", "bash" }

--------------------------------------------------------------------------------

return {
	-- TODO
	-- 1. fix signature help
	-- 2. fix gui-cursor being ignored
	{ -- UI overhaul
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		event = "VeryLazy",
		init = function()
			-- Open Log & Scroll to most recent message
			vim.keymap.set("n", "<D-0>", function()
				vim.cmd.Noice("history")
				vim.defer_fn(function()
					if vim.bo.filetype == "noice" then u.normal("G") end
				end, 1)
			end, { desc = "󰎟 Notification Log" })

			-- set some keybindings for the Noice buffer
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "noice",
				callback = function()
					vim.keymap.set("n", "<D-w>", vim.cmd.quit, { buffer = true, desc = " Close" })
					vim.keymap.set("n", "<D-0>", vim.cmd.quit, { buffer = true, desc = " Close" })
				end,
			})
		end,
		opts = {
			-- can be used to filter/redirect stuff
			-- https://www.reddit.com/r/neovim/comments/12lf0ke/comment/jg6idvr/?utm_source=share&utm_medium=web2x&context=3
			-- https://github.com/folke/noice.nvim#-routes
			routes = {
				-- redirect stuff to the more subtle "mini"
				-- { filter = { event = "msg_show", find = "^%[nvim%-treesitter%]" }, view = "mini" },
				-- { filter = { event = "notify", find = "successfully u?n?installed.$" }, view = "mini" },
				-- { filter = { event = "notify", find = "^%[mason%-" }, view = "mini" },

				-- unneeded info on search patterns
				{ filter = { event = "msg_show", find = "^/." }, skip = true },
				{ filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },
			},
			cmdline = {
				-- classic cmdline at the bottom to not obfuscate the buffer, e.g.
				-- for :substitute or numb.vnim
				view = "cmdline",
				format = {
					search_down = { icon = "  " },
					cmdline = { icon = " " },
					-- syntax highlighting for `:I`, (see config/user-commands.lua)
					inspect = { pattern = "^:I", icon = " ", ft = "lua" },
				},
			},
			views = {
				cmdline_popup = { border = { style = u.borderStyle } },
				-- avoid overlap with notify
				-- mini = { zindex = 10 },
			},

			-- DISABLED, since conflicts with existing plugins (which I find better)
			popupmenu = { backend = "cmp" }, -- replace with nvim-cmp, since more sources
			messages = { view_search = false }, -- replaced by custom lualine component
			lsp = {
				progress = { enabled = false }, -- replaced with nvim-dr-lsp
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
		event = "VeryLazy",
		opts = {
			-- HACK fix missing padding: https://github.com/rcarriga/nvim-notify/issues/152
			render = function(bufnr, notif, highlights)
				local base = require("notify.render.base")
				local namespace = base.namespace()
				local padded_message = vim.tbl_map(function(line) return " " .. line end, notif.message)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, padded_message)

				vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
					hl_group = highlights.icon,
					end_line = #notif.message - 1,
					end_col = #notif.message[#notif.message],
					priority = 50,
				})
			end,
			stages = "slide",
			level = 0, -- minimum severity level to display (0 = display all)
			max_height = 30,
			-- max_width = 50,
			minimum_width = 13,
			timeout = 4000,
			top_down = false,
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
				local history = require("notify").history {}
				local lastNotify = history[#history]
				if not lastNotify then
					vim.notify("No Notification in this session.", u.warn)
					return
				end
				local msg = ""
				for _, line in pairs(lastNotify.message) do
					msg = msg .. line .. "\n"
				end
				vim.fn.setreg("+", msg)
				vim.notify("Last Notification copied.\n" .. msg, u.trace)
			end, { desc = "󰎟 Copy Last Notification" })
		end,
	},
	{ -- rainbow brackets
		"https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
		event = "BufEnter",
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
				lazy = { icon = "", name = "Lazy" },
				mason = { icon = "", name = "Mason" },
			},
		},
	},
	{ -- Scrollbar, also shows search matches and gitsigns
		"dstein64/nvim-scrollview",
		event = "VeryLazy",
		dependencies = "neovim/nvim-lspconfig",
		config = function()
			require("scrollview").setup {
				winblend = 40,
				column = 1,
				signs_on_startup = { "conflicts", "search", "diagnostics", "quickfix", "folds" },
				refresh_mapping_desc = "which_key_ignore",
				quickfix_symbol = "󰉀 ",
				folds_symbol = " ",
				search_symbol = { "⠂", "⠅", "⠇", "⠗", "⠟", "⠿" },
			}
			-- add gitsigns https://github.com/dstein64/nvim-scrollview/blob/main/lua/scrollview/contrib/gitsigns.lua
			require("scrollview.contrib.gitsigns").setup()
		end,
	},
	{ -- emphasized undo/redos
		"tzachar/highlight-undo.nvim",
		keys = { "u", "U" },
		opts = {
			duration = 250,
			keymaps = {
				{ "n", "u", "silent undo", { desc = "󰕌 Undo", silent = true } },
				{ "n", "U", "silent redo", { desc = "󰑎 Redo", silent = true } },
			},
		},
	},
	{ -- color previews & color picker
		"uga-rosa/ccc.nvim",
		keys = {
			{ "#", vim.cmd.CccPick, desc = " Color Picker" },
			{ "'", vim.cmd.CccConvert, desc = " Convert Color" }, -- shift-# on German keyboard
		},
		ft = colorPickerFts,
		config = function()
			vim.opt.termguicolors = true
			local ccc = require("ccc")
			ccc.setup {
				win_opts = { border = u.borderStyle },
				highlighter = {
					auto_enable = true,
					max_byte = 2 * 1024 * 1024, -- 2mb
					lsp = true,
					filetypes = colorPickerFts,
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
	{ -- Better input/selection fields
		"stevearc/dressing.nvim",
		event = "VeryLazy",
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
