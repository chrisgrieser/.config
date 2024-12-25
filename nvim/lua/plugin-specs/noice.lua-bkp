-- highlighting of filepaths and error codes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "noice", "snacks_notif", "snacks_win" },
	callback = function(ctx)
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(ctx.buf) then return end
			vim.api.nvim_buf_call(ctx.buf, function()
				vim.fn.matchadd("WarningMsg", [[[^/]\+\.lua:\d\+\ze:]])
				vim.fn.matchadd("WarningMsg", [[E\d\+]])
			end)
		end, 1)
	end,
})

--------------------------------------------------------------------------------

-- DOCS https://github.com/folke/noice.nvim#-routes
local routes = {
	-- write/deletion messages
	{ filter = { event = "msg_show", find = "%d+B written$" }, view = "mini" },
	{ filter = { event = "msg_show", find = "%d+L, %d+B$" }, view = "mini" },
	{ filter = { event = "msg_show", find = "%-%-No lines in buffer%-%-" }, view = "mini" },

	-- gitsigns.nvim
	{ filter = { event = "msg_show", find = "^Hunk %d+ of %d+" }, view = "mini" },
	{ filter = { event = "msg_show", find = "^No hunks$" }, view = "mini" },

	-- nvim-treesitter
	{ filter = { event = "msg_show", find = "^%[nvim%-treesitter%]" }, view = "mini" },
	{ filter = { event = "notify", find = "All parsers are up%-to%-date" }, view = "mini" },

	-- word added to spellfile via `zg`
	{ filter = { event = "msg_show", find = "^Word .*%.add$" }, view = "mini" },

	-- search
	{ filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },

	--------------------------------------------------------------------

	-- FIX https://github.com/artempyanykh/marksman/issues/348
	{ filter = { event = "notify", find = "^Client marksman quit with" }, skip = true },

	-- code actions
	{ filter = { event = "notify", find = "No code actions available" }, skip = true },

	-- unneeded info on search patterns when pattern not found
	{ filter = { event = "msg_show", find = "^[/?]." }, skip = true },
}

--------------------------------------------------------------------------------

return {
	"folke/noice.nvim",
	event = "BufReadPre",
	keys = {
		{ "<Esc>", vim.cmd.NoiceDismiss, desc = "󰎟 Clear notifications" },
		-- stylua: ignore
		{ "<D-0>", vim.cmd.NoiceHistory, mode = { "n", "v", "i" }, desc = "󰎟 All notifications" },
	},
	opts = {
		routes = routes,
		cmdline = {
			format = {
				search_down = { icon = "  ", view = "cmdline" },
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
			mini = {
				timeout = 3000,
				zindex = 45, -- lower than nvim-notify (50), higher than satellite-scrollbar (40)
				format = { "{title} ", "{message}" }, -- leave out "{level}"
			},
			split = {
				enter = true,
				size = "70%",
				win_options = { scrolloff = 6 },
				close = { keys = { "q", "<D-w>", "<D-9>", "<D-0>" } },
			},
		},
		commands = {
			history = {
				filter_opts = { reverse = true }, -- show newest entries first
				opts = { format = { "{title} ", "{message}" } }, -- https://github.com/folke/noice.nvim#-formatting
				filter = {
					["not"] = {
						any = {
							{ find = "^/" }, -- skip search messages
							{ -- skip trace level messages
								event = "notify",
								cond = function(msg) return msg.level and msg.level == "trace" end,
							},
						},
					},
				},
			},
		},
		lsp = {
			progress = { enabled = false }, -- using my own
			signature = { enabled = false }, -- using lsp_signature.nvim
		},
	},
}
