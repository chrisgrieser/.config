local u = require("config.utils")

---@param bufnr number
local function highlightsInStacktrace(bufnr)
	vim.defer_fn(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then return end
		vim.api.nvim_buf_call(bufnr, function()
			vim.fn.matchadd("WarningMsg", [[[^/]\+\.lua:\d\+\ze:]]) -- files with error
			vim.fn.matchadd("WarningMsg", [[[E\d\+]]) -- vim error codes
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
	-- output from `:Inspect`
	{ filter = { event = "msg_show", find = "Treesitter.*- @" }, view = "popup" },

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

	-- supermaven, -- PENDING https://github.com/supermaven-inc/supermaven-nvim/issues/18
	{ filter = { event = "msg_show", find = "Supermaven Free Tier is running." }, skip = true },

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
				callback = function(ctx)
					highlightsInStacktrace(ctx.buf)
					-- do not let noice override my versions of the mappings
					vim.defer_fn(function()
						pcall(vim.keymap.del, "n", "K", { buffer = ctx.buf })
						pcall(vim.keymap.del, "n", "gx", { buffer = ctx.buf })
					end, 1)
				end,
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
				format = {
					search_down = { icon = "  ", view = "cmdline" },
				},
			},
			-- DOCS https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
			views = {
				cmdline_popup = {
					border = { style = vim.g.borderStyle },
				},
				mini = {
					timeout = 3000,
					zindex = 4, -- lower, so it does not cover nvim-notify (zindex 50)
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
					opts = { format = { "{title} ", "{cmdline} ", "{message}" } },
				},
			},

			-- DISABLE features, since conflicts with existing plugins I prefer to use
			lsp = {
				progress = { enabled = false }, -- using my own statusline component instead
				signature = { enabled = false }, -- using `lsp_signature.nvim` instead

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
			max_width = 50,
			minimum_width = 25, -- wider for title in border
			top_down = false,
			level = 0, -- minimum severity, 0 = show all
			stages = "slide",
			icons = { ERROR = "", WARN = "", INFO = "", DEBUG = "", TRACE = "" },

			-- PENDING https://github.com/rcarriga/nvim-notify/pull/280
			-- render = "wrapped-minimal",
			render = require("funcs.TEMP-wrapped-minimal"),
			on_open = function(win, record)
				if not vim.api.nvim_win_is_valid(win) then return end

				-- put title into border PENDING https://github.com/rcarriga/nvim-notify/issues/279
				local opts = { border = vim.g.borderStyle }
				local hasTitle = record.title[1] and record.title[1] ~= ""
				if hasTitle then
					local title = " " .. record.title[1] .. " "
					if record.level ~= "INFO" then title = " " .. record.icon .. title end
					local titleHl = ("Notify%sTitle"):format(record.level)
					opts.title = { { title, titleHl } }
					opts.title_pos = "left"
				end
				vim.api.nvim_win_set_config(win, opts)

				local bufnr = vim.api.nvim_win_get_buf(win)
				highlightsInStacktrace(bufnr)
			end,
		},
	},
}
