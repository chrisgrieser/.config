-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md#%EF%B8%8F-config
--------------------------------------------------------------------------

---@param idx number|"last"
local function openNotif(idx)
	-- CONFIG
	local maxWidth = 0.85
	local maxHeight = 0.85

	-- get notification
	if idx == "last" then idx = 1 end
	local history = require("snacks").notifier.get_history {
		filter = function(notif) return notif.level ~= "trace" end,
		reverse = true,
	}
	local notif = history[idx]
	if not notif then
		local msg = "No notifications yet."
		vim.notify(msg, vim.log.levels.TRACE, { title = "Last notification", icon = "󰎟" })
		return
	end
	require("snacks").notifier.hide(notif.id)

	-- win properties
	local bufnr = vim.api.nvim_create_buf(false, true)
	local lines = vim.split(notif.msg, "\n")
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	local title = vim.trim((notif.icon or "") .. " " .. (notif.title or ""))
	local height = math.min(#lines + 2, math.ceil(vim.o.lines * maxHeight))
	local longestLine = vim.iter(lines):fold(0, function(acc, line) return math.max(acc, #line) end)
	longestLine = math.max(longestLine, #title)
	local width = math.min(longestLine + 3, math.ceil(vim.o.columns * maxWidth))
	local overflow = #lines + 2 - height -- +2 for border
	local moreLines = overflow > 0 and (" ↓ %d lines "):format(overflow) or ""
	local indexStr = ("(%d/%d)"):format(idx, #history)
	local footer = vim.trim(indexStr .. " " .. moreLines)

	local levelCapitalized = notif.level:sub(1, 1):upper() .. notif.level:sub(2)
	local highlights = {
		"Normal:SnacksNormal",
		"NormalNC:SnacksNormalNC",
		"FloatBorder:SnacksNotifierBorder" .. levelCapitalized,
		"FloatTitle:SnacksNotifierTitle" .. levelCapitalized,
		"FloatFooter:SnacksNotifierFooter" .. levelCapitalized,
	}

	-- create win with snacks API
	require("snacks").win {
		position = "float",
		ft = notif.ft or "markdown",
		buf = bufnr,
		height = height,
		width = width,
		title = vim.trim(title) ~= "" and " " .. title .. " " or nil,
		footer = footer and " " .. footer .. " " or nil,
		footer_pos = footer and "right" or nil,
		wo = { ---@diagnostic disable-line: missing-fields -- faulty annotation
			winhighlight = table.concat(highlights, ","),
			wrap = true, -- only one message, so use full space
		},
		keys = {
			["<Tab>"] = function()
				if idx == #history then return end
				vim.cmd.close()
				openNotif(idx + 1)
			end,
			["<S-Tab>"] = function()
				if idx == 1 then return end
				vim.cmd.close()
				openNotif(idx - 1)
			end,
		},
	}
end

--------------------------------------------------------------------------------

return {
	{ -- Message & command system overhaul
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {},
		keys = {
			{ "<Esc>", vim.cmd.NoiceDismiss, desc = "󰎟 Clear notifications" },
			-- stylua: ignore
			{ "<D-0>", vim.cmd.NoiceHistory, mode = { "n", "v", "i" }, desc = "󰎟 All notifications" },
		},
		opts = {
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
			routes = {
				-- DOCS https://github.com/folke/noice.nvim#-routes
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

				{ -- mason.nvim
					filter = {
						event = "notify",
						cond = function(msg) return msg.opts and (msg.opts.title or ""):find("mason") end,
					},
					view = "mini",
				},
				-- word added to spellfile via `zg`
				{ filter = { event = "msg_show", find = "^Word .*%.add$" }, view = "mini" },
				--------------------------------------------------------------------

				-- search
				{ filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },

				-- FIX https://github.com/artempyanykh/marksman/issues/348
				{ filter = { event = "notify", find = "^Client marksman quit with" }, skip = true },

				-- code actions
				{ filter = { event = "notify", find = "No code actions available" }, skip = true },

				-- unneeded info on search patterns when pattern not found
				{ filter = { event = "msg_show", find = "^[/?]." }, skip = true },
			},
			lsp = {
				progress = { enabled = false }, -- using my own
				signature = { enabled = false }, -- using lsp_signature.nvim
			},
		},
	},
	{ -- mostly used for its notifications
		"folke/snacks.nvim",
		event = "VeryLazy",
		keys = {
			-- stylua: ignore start
			{ "ö", function() require("snacks").words.jump(1, true) end, desc = "󰉚 Next reference" },
			{ "Ö", function() require("snacks").words.jump(-1, true) end, desc = "󰉚 Prev reference" },
			{ "<leader>g?", function() require("snacks").git.blame_line() end, desc = "󰉚 Blame line" },
			{ "<D-9>", function() openNotif("last") end, mode = { "n", "v", "i" }, desc = "󰎟 Last notification" },
			-- stylua: ignore end
		},
		opts = {
			words = {
				notify_jump = true,
				modes = { "n" },
				debounce = 300,
			},
			win = {
				border = vim.g.borderStyle,
				bo = { modifiable = false },
				wo = { cursorline = true, colorcolumn = "", winfixbuf = true },
				keys = { q = "close", ["<Esc>"] = "close", ["<D-9>"] = "close", ["<D-0>"] = "close" },
			},
			notifier = {
				timeout = 7500,
				sort = { "added" }, -- sort only by time
				width = { min = 12, max = 0.5 },
				height = { min = 1, max = 0.5 },
				icons = { error = "", warn = "", info = "", debug = "", trace = "󰓘" },
				top_down = false,
			},
			styles = {
				notification = {
					border = vim.g.borderStyle,
					wo = { cursorline = false, winblend = 0, wrap = true },
				},
				blame_line = {
					width = 0.6,
					height = 0.6,
					border = vim.g.borderStyle,
					title = " 󰉚 Git blame ",
				},
			},
		},
	},
}
