---@param bufnr number
local function highlightsInStacktrace(bufnr)
	vim.defer_fn(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then return end
		vim.api.nvim_buf_call(bufnr, function()
			vim.fn.matchadd("WarningMsg", [[[^/]\+\.lua:\d\+\ze:]]) -- files with error
			vim.fn.matchadd("WarningMsg", [[E\d\+]]) -- vim error codes
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
			cond = function(msg)
				local title = (msg.opts and msg.opts.title) or ""
				return not title:find("tinygit") and not title:find("Magnet")
			end,
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

	-- gitsigns
	{ filter = { event = "msg_show", find = "Hunk %d+ of %d+" }, view = "mini" },

	-----------------------------------------------------------------------------
	-- SKIP

	-- FIX LSP bugs?
	{ filter = { event = "msg_show", find = "lsp_signature? handler RPC" }, skip = true },
	-- stylua: ignore
	{ filter = { event = "msg_show", find = "^%s*at process.processTicksAndRejections" }, skip = true },

	-- code actions
	{ filter = { event = "notify", find = "No code actions available" }, skip = true },

	-- unneeded info on search patterns
	{ filter = { event = "msg_show", find = "^[/?]." }, skip = true },
}

--------------------------------------------------------------------------------

return {
	{ -- Message & Command System Overhaul
		"folke/noice.nvim",
		event = "UIEnter",
		version = "4.4.7", -- PENDING https://github.com/folke/noice.nvim/issues/923
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "noice",
				callback = function(ctx) highlightsInStacktrace(ctx.buf) end,
			})
		end,
		keys = {
			{ "<Esc>", vim.cmd.NoiceDismiss, desc = "󰎟 Clear Notifications" },
			{ "<D-0>", vim.cmd.NoiceHistory, mode = { "n", "x", "i" }, desc = "󰎟 Noice Log" },
			{ "<D-9>", vim.cmd.NoiceLast, mode = { "n", "x", "i" }, desc = "󰎟 Noice Last" },
			{ "<D-8>", vim.cmd.NoiceErrors, mode = { "n", "x", "i" }, desc = "󰎟 Noice Errors" },
		},
		opts = {
			routes = routes,
			messages = { view_search = false },
			cmdline = {
				format = {
					search_down = { icon = "  ", view = "cmdline" },
					-- formatting for`:Eval`(custom `:lua=` replacement)
					eval = {
						pattern = "^:Eval%s+",
						lang = "lua",
						icon = "",
						icon_hl_group = "@constant",
					},
				},
			},
			-- DOCS https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
			views = {
				cmdline_popup = {
					border = { style = vim.g.borderStyle },
				},
				cmdline_popupmenu = {
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
				hover = {
					border = { style = vim.g.borderStyle },
					size = { max_width = 80 },
					win_options = { scrolloff = 4, wrap = true },
				},
				popup = {
					border = { style = vim.g.borderStyle },
					size = { width = 90, height = 25 },
					win_options = { scrolloff = 8, wrap = true, concealcursor = "ncv" },
					close = { keys = { "q", "<D-w>", "<D-9>", "<D-0>", "<D-8>" } },
					format = { "{message}" },
				},
				split = {
					enter = true,
					size = "60%",
					win_options = { scrolloff = 6 },
					close = { keys = { "q", "<D-w>", "<D-9>", "<D-0>", "<D-8>" } },
				},
			},
			commands = {
				history = {
					filter_opts = { reverse = true }, -- show newest entries first
					-- https://github.com/folke/noice.nvim#-formatting
					opts = { format = { "{title} ", "{message}" } },
				},
				last = {
					opts = { format = { "{title} ", "{message}" } },
				},
				errors = {
					opts = { format = { "{title} ", "{message}" } },
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
