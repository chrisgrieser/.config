local u = require("config.utils")
local trace = vim.log.levels.TRACE
--------------------------------------------------------------------------------

-- DOCS https://github.com/folke/noice.nvim#-routes
local routes = {
	-- redirect to popup when message is longer than 10 lines
	{ filter = { min_height = 10 }, view = "popup" },

	-- write/deletion messages
	{ filter = { event = "msg_show", find = "%d+B written$" }, view = "mini" },
	{ filter = { event = "msg_show", find = "%d+L, %d+B$" }, view = "mini" },
	{ filter = { event = "msg_show", find = "%-%-No lines in buffer%-%-" }, view = "mini" },

	-- :cdo
	{ filter = { event = "msg_show", find = "%d+ lines %-%-%d+%%%-%-" }, skip = true },

	-- unneeded info on search patterns
	{ filter = { event = "msg_show", find = "^[/?]." }, skip = true },
	{ filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },

	-- Word added to spellfile via `zg`
	{ filter = { event = "msg_show", find = "^Word .*%.add$" }, view = "mini" },

	-- Diagnostics
	{
		filter = { event = "msg_show", find = "No more valid diagnostics to move to" },
		view = "mini",
	},

	-- :make
	{ filter = { event = "msg_show", find = "^:!make" }, skip = true },
	{ filter = { event = "msg_show", find = "^%(%d+ of %d+%):" }, skip = true },

	-----------------------------------------------------------------------------
	{ -- nvim-early-retirement
		filter = {
			event = "notify",
			cond = function(msg) return msg.opts and msg.opts.title == "Auto-Closing Buffer" end,
		},
		view = "mini",
	},

	-- nvim-treesitter
	{ filter = { event = "msg_show", find = "^%[nvim%-treesitter%]" }, view = "mini" },
	{ filter = { event = "notify", find = "All parsers are up%-to%-date" }, view = "mini" },

	-- Mason
	{ filter = { event = "notify", find = "%[mason%-tool%-installer%]" }, view = "mini" },
	{
		filter = {
			event = "notify",
			cond = function(msg)
				return msg.opts and msg.opts.title and msg.opts.title:find("mason.*.nvim")
			end,
		},
		view = "mini",
	},
}

--------------------------------------------------------------------------------

return {
	{ -- Message & Command System Overhaul
		"folke/noice.nvim",
		event = "VimEnter", -- earlier to catch notifications on startup
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		keys = {
			{ "<Esc>", function() vim.cmd.Noice("dismiss") end, desc = "󰎟 Clear Notifications" },
			{
				"<D-0>",
				function()
					vim.cmd.Noice("dismiss")
					vim.cmd.Noice("history")
				end,
				mode = { "n", "x", "i" },
				desc = "󰎟 Noice Log",
			},
			{
				"<D-k>",
				function()
					vim.cmd.close()
					vim.cmd.Lazy("reload noice.nvim")
					vim.notify("Noice Log cleared.", trace, { title = "noice.nvim" })
				end,
				ft = "noice", -- only work in noice log itself
				desc = "󰎟 Clear Noice Log",
			},
		},
		opts = {
			routes = routes,
			cmdline = {
				view = "cmdline", -- cmdline|cmdline_popup
				format = {
					search_down = { icon = "  ", view = "cmdline" }, -- FIX needs to be set explicitly
					cmdline = { view = "cmdline_popup" },
					lua = { view = "cmdline_popup" },
					help = { view = "cmdline_popup" },
				},
			},
			-- DOCS https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
			views = {
				cmdline_popup = {
					border = { style = u.borderStyle },
				},
				mini = {
					timeout = 3000,
					zindex = 10, -- lower, so it does not cover nvim-notify
					position = { col = -3 }, -- to the left to avoid collision with scrollbar
				},
				hover = {
					border = { style = u.borderStyle },
					size = { max_width = 80 },
					win_options = { scrolloff = 4, wrap = true },
				},
				popup = {
					border = { style = u.borderStyle },
					size = { width = 90, height = 25 },
					win_options = { scrolloff = 8, wrap = true },
				},
				split = {
					enter = true,
					size = "50%",
					close = { keys = { "q", "<D-w>", "<D-0>" } },
					win_options = { scrolloff = 3 },
				},
			},
			commands = {
				-- options for `:Noice history`
				history = {
					view = "split",
					filter_opts = { reverse = true }, -- show newest entries first
					filter = {}, -- empty list = deactivate filter = include everything
					opts = {
						enter = true,
						-- https://github.com/folke/noice.nvim#-formatting
						format = { "{title} ", "{cmdline} ", "{message}" },
					},
				},
			},

			-- DISABLE features, since conflicts with existing plugins I prefer to use
			messages = { view_search = false }, -- replaced by nvim-hlslens
			lsp = {
				progress = { enabled = false }, -- replaced with nvim-dr-lsp, since less intrusive
				signature = { enabled = false }, -- using with lsp_signature.nvim

				-- ENABLE features
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
		},
	},
	{ -- Notifications
		"rcarriga/nvim-notify",
		keys = {
			{
				"<leader>ln",
				function()
					local history = require("notify").history()
					if #history == 0 then
						vim.notify("No Notification in this session.", trace, { title = "nvim-notify" })
						return
					end
					local msg = history[#history].message
					vim.fn.setreg("+", msg)
					vim.notify("Last Notification copied.", trace, { title = "nvim-notify" })
				end,
				desc = "󰎟 Copy Last Notification",
			},
		},
		opts = {
			render = "wrapped-compact",
			top_down = false,
			max_width = 50, -- commit message max length
			minimum_width = 15,
			level = trace, -- minimum severity
			timeout = 6000,
			stages = "slide", -- slide|fade
			icons = { DEBUG = "", ERROR = "", INFO = "", TRACE = "", WARN = "" },
			on_open = function(win)
				-- set borderstyle
				if not vim.api.nvim_win_is_valid(win) then return end
				vim.api.nvim_win_set_config(win, { border = u.borderStyle })
			end,
		},
	},
}
