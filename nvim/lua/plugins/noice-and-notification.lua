local u = require("config.utils")

---@param bufnr number
local function highlightsInStacktrace(bufnr)
	vim.defer_fn(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then return end
		vim.api.nvim_buf_call(bufnr, function()
			vim.fn.matchadd("WarningMsg", [[[^/]\+\.lua:\d\+\ze:]]) -- \ze: lookahead
		end)
	end, 1)
end

--------------------------------------------------------------------------------

-- DOCS https://github.com/folke/noice.nvim#-routes
local routes = {
	-- REDIRECT TO POPUP
	{
		filter = {
			min_height = 10,
			["not"] = {
				cond = function(msg)
					local title = (msg.opts and msg.opts.title) or ""
					return title:find("Commit Preview")
						or title:find("tinygit")
						or title:find("Changed Files")
				end,
			},
		},
		view = "popup",
	},

	-----------------------------------------------------------------------------
	-- REDIRECT TO MINI

	-- write/deletion messages
	{ filter = { event = "msg_show", find = "%d+B written$" }, view = "mini" },
	{ filter = { event = "msg_show", find = "%d+L, %d+B$" }, view = "mini" },
	{ filter = { event = "msg_show", find = "%-%-No lines in buffer%-%-" }, view = "mini" },

	-- search pattern not found
	{ filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },

	-- Word added to spellfile via `zg`
	{ filter = { event = "msg_show", find = "^Word .*%.add$" }, view = "mini" },

	{ -- Mason
		filter = {
			event = "notify",
			cond = function(msg) return msg.opts and (msg.opts.title or ""):find("mason") end,
		},
		view = "mini",
	},

	-- nvim-treesitter
	{ filter = { event = "msg_show", find = "^%[nvim%-treesitter%]" }, view = "mini" },
	{ filter = { event = "notify", find = "All parsers are up%-to%-date" }, view = "mini" },

	-----------------------------------------------------------------------------
	-- SKIP

	-- FIX LSP bugs?
	{ filter = { event = "msg_show", find = "lsp_signature? handler RPC" }, skip = true },
	{
		filter = { event = "msg_show", find = "^%s*at process.processTicksAndRejections" },
		skip = true,
	},

	-- code actions
	{ filter = { event = "notify", find = "No code actions available" }, skip = true },

	-- unneeded info on search patterns
	{ filter = { event = "msg_show", find = "^[/?]." }, skip = true },

	-- :make
	{ filter = { event = "msg_show", find = "^:!make" }, skip = true },
	{ filter = { event = "msg_show", find = "^%(%d+ of %d+%):" }, skip = true },

	-- E211 no longer needed, since auto-closing deleted buffers
	{ filter = { event = "msg_show", find = "E211: File .* no longer available" }, skip = true },
}

--------------------------------------------------------------------------------

return {
	{ -- Message & Command System Overhaul
		"folke/noice.nvim",
		event = "VimEnter", -- earlier to catch notifications on startup
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "noice",
				callback = function(ctx) highlightsInStacktrace(ctx.buf) end,
			})
			u.colorschemeMod("NoiceCmdline", { link = "NormalFloat" })
		end,
		keys = {
			{
				"<Esc>",
				function()
					vim.snippet.stop()
					vim.cmd.NoiceDismiss()
				end,
				desc = "󰎟 Clear Notifications & Snippet",
			},
			{ "<D-0>", vim.cmd.NoiceHistory, mode = { "n", "x", "i" }, desc = "󰎟 Noice Log" },
			{ "<D-9>", vim.cmd.NoiceLast, mode = { "n", "x", "i" }, desc = "󰎟 Noice Last" },
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
					border = { style = vim.g.borderStyle },
				},
				mini = {
					timeout = 3000,
					zindex = 10, -- lower, so it does not cover nvim-notify
					position = { col = -3 }, -- to the left to avoid collision with scrollbar
					format = { "{title} ", "{message}" }, -- leave out "{level}"
				},
				hover = {
					border = { style = vim.g.borderStyle },
					size = { max_width = 80 },
					win_options = { scrolloff = 4, wrap = true },
				},
				popup = {
					border = { style = vim.g.borderStyle },
					size = { width = 90, height = 25 },
					win_options = { scrolloff = 8, wrap = true, concealcursor = "nv" },
					close = { keys = { "q", "<D-w>", "<D-9>", "<D-0>" } },
				},
				split = {
					enter = true,
					size = "50%",
					win_options = { scrolloff = 6 },
					close = { keys = { "q", "<D-w>", "<D-9>", "<D-0>" } },
				},
			},
			commands = {
				history = {
					view = "split",
					filter_opts = { reverse = true }, -- show newest entries first
					-- https://github.com/folke/noice.nvim#-formatting
					opts = { format = { "{title} ", "{cmdline} ", "{message}" } },
				},
				last = {
					view = "popup",
					-- https://github.com/folke/noice.nvim#-formatting
					opts = { format = { "{title} ", "{cmdline} ", "{message}" } },
				},
			},

			-- DISABLE features, since conflicts with existing plugins I prefer to use
			lsp = {
				progress = { enabled = false },
				signature = { enabled = false }, -- using lsp_signature.nvim instead

				-- ENABLE features
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
		},
	},
	{
		"rcarriga/nvim-notify",
		opts = {
			render = "wrapped-compact", -- best for shorter max_width
			max_width = math.floor(vim.o.columns * 0.4),
			minimum_width = 15,
			top_down = false,
			level = vim.log.levels.TRACE, -- minimum severity
			timeout = 4000,
			stages = "slide", -- slide|fade
			icons = { ERROR = "", WARN = "▲", INFO = "●", TRACE = "", DEBUG = "" },
			on_open = function(win)
				-- set borderstyle
				if not vim.api.nvim_win_is_valid(win) then return end
				vim.api.nvim_win_set_config(win, { border = vim.g.borderStyle })

				local bufnr = vim.api.nvim_win_get_buf(win)
				highlightsInStacktrace(bufnr)
			end,
		},
	},
}
