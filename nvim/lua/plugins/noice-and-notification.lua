-- highlighting of filepaths and error codes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "noice", "snacks_notif" },
	callback = function(ctx)
		vim.defer_fn(function()
			vim.api.nvim_buf_call(ctx.buf, function()
				vim.fn.matchadd("WarningMsg", [[[^/]\+\.lua:\d\+\ze:]])
				vim.fn.matchadd("WarningMsg", [[E\d\+]])
			end)
		end, 1)
	end,
})

--------------------------------------------------------------------------

-- DOCS https://github.com/folke/noice.nvim#-routes
local routes = {
	-- REDIRECT TO POPUP
	{
		filter = {
			min_height = 10,
			cond = function(msg)
				local title = (msg.opts and msg.opts.title) or ""
				return not title:find("tinygit") and not title:find("lazy%.nvim")
			end,
		},
		view = "popup",
	},

	-- output from `:Inspect`, for easier copying
	{ filter = { event = "msg_show", find = "Treesitter.*- @" }, view = "popup" },

	-----------------------------------------------------------------------------
	-- REDIRECT TO MINI

	-- write/deletion messages
	{ filter = { event = "msg_show", find = "%d+B written$" }, view = "mini" },
	{ filter = { event = "msg_show", find = "%d+L, %d+B$" }, view = "mini" },
	{ filter = { event = "msg_show", find = "%-%-No lines in buffer%-%-" }, view = "mini" },

	-- search
	{ filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },

	-- word added to spellfile via `zg`
	{ filter = { event = "msg_show", find = "^Word .*%.add$" }, view = "mini" },

	-- gitsigns.nvim
	{ filter = { event = "msg_show", find = "Hunk %d+ of %d+" }, view = "mini" },
	{ filter = { event = "msg_show", find = "No hunks" }, view = "mini" },

	-- nvim-treesitter
	{ filter = { event = "msg_show", find = "^%[nvim%-treesitter%]" }, view = "mini" },
	{ filter = { event = "notify", find = "All parsers are up%-to%-date" }, view = "mini" },

	-----------------------------------------------------------------------------
	-- SKIP

	-- FIX LSP bugs?
	{ filter = { event = "msg_show", find = "lsp_signature? handler RPC" }, skip = true },
	-- stylua: ignore
	{ filter = { event = "msg_show", find = "^%s*at process.processTicksAndRejections" }, skip = true },

	-- code actions
	{ filter = { event = "notify", find = "No code actions available" }, skip = true },

	-- unneeded info on search patterns when pattern not found
	{ filter = { event = "msg_show", find = "^[/?]." }, skip = true },

	-- useless notification when closing buffers
	{
		filter = { event = "notify", find = "^Client marksman quit with exit code 1 and signal 0." },
		skip = true,
	},
}

--------------------------------------------------------------------------------

return {
	{ -- notification & other utilities
		"folke/snacks.nvim",
		event = "UIEnter",
		keys = {
			{
				"ö",
				function()
					vim.cmd.normal { "m`", bang = true }
					require("snacks").words.jump(1, true)
					vim.cmd.normal { "zv", bang = true }
				end,
				desc = "󰒕 Next Reference",
			},
			{
				"Ö",
				function()
					vim.cmd.normal { "m`", bang = true }
					require("snacks").words.jump(-1, true)
					vim.cmd.normal { "zv", bang = true }
				end,
				desc = "󰒕 Prev Reference",
			},
		},
		opts = {
			bigfile = { enabled = false },
			quickfile = { enabled = false },
			statuscolumn = { enabled = false },
			words = {
				notify_jump = true,
				modes = { "n" },
			},

			styles = {
				notification = {
					wo = { wrap = true, winblend = 0 },
					border = vim.g.borderStyle,
				},
			},
			notifier = {
				timeout = 6000,
				width = { min = 20, max = 0.45 },
				height = { min = 1, max = 0.4 },
				icons = { error = "", warn = "", info = "", debug = "", trace = "󰓘" },
				top_down = false,
			},
		},
	},
	{ -- Message & Command System Overhaul
		"folke/noice.nvim",
		event = "UIEnter",
		dependencies = "MunifTanjim/nui.nvim",
		keys = {
			{ "<Esc>", vim.cmd.NoiceDismiss, desc = "󰎟 Clear Notifications" },
			{ "<D-0>", vim.cmd.NoiceHistory, mode = { "n", "x", "i" }, desc = "󰎟 Noice Log" },
			{ "<D-9>", vim.cmd.NoiceLast, mode = { "n", "x", "i" }, desc = "󰎟 Noice Last" },
		},
		opts = {
			routes = routes,
			messages = { view_search = false },
			cmdline = {
				format = {
					search_down = { icon = "  ", view = "cmdline" },
					eval = { -- formatting for`:Eval`(my custom `:lua=` replacement)
						pattern = "^:Eval%s+",
						lang = "lua",
						icon = "󰓗",
						icon_hl_group = "@constant",
					},
				},
			},
			-- DOCS https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
			views = {
				cmdline_popup = {
					border = { style = vim.g.borderStyle },
				},
				cmdline_popupmenu = { -- the completions window
					size = { max_height = 12 },
					border = { padding = { 0, 1 } }, -- setting border style messes up automatic positioning
					win_options = {
						winhighlight = { Normal = "NormalFloat", FloatBorder = "NoicePopupmenuBorder" },
					},
				},
				cmdline = {
					win_options = { winhighlight = { Normal = "NormalFloat" } },
				},
				mini = {
					timeout = 3000,
					zindex = 45, -- lower than nvim-notify (50), higher than satellite-scrollbar (40)
					format = { "{title} ", "{message}" }, -- leave out "{level}"
				},
				popup = {
					border = { style = vim.g.borderStyle },
					size = { width = 90, height = 25 },
					win_options = { scrolloff = 8, wrap = true, concealcursor = "ncv" },
					close = { keys = { "q", "<D-w>", "<D-9>", "<D-0>" } },
					format = { "{message}" },
				},
				split = {
					enter = true,
					size = "65%",
					win_options = { scrolloff = 6 },
					close = { keys = { "q", "<D-w>", "<D-9>", "<D-0>" } },
				},
			},
			commands = {
				history = {
					filter_opts = { reverse = true }, -- show newest entries first
					opts = { format = { "{title} ", "{message}" } }, -- https://github.com/folke/noice.nvim#-formatting
					filter = { ["not"] = { find = "^/" } }, -- skip search messages
				},
				last = {
					opts = { format = { "{title} ", "{message}" } },
					filter = { ["not"] = { find = "^/" } }, -- skip search messages
				},
			},
			notify = {
				merge = true,
			},

			-- DISABLE features, since conflicts with existing plugins I prefer to use
			lsp = {
				progress = { enabled = false }, -- using my own statusline component instead
				signature = { enabled = false }, -- using `lsp_signature.nvim` instead

				-- ENABLE features
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
		},
	},
}
