-- DOCS Snacks.notifier
-- https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md#%EF%B8%8F-config
--------------------------------------------------------------------------

---@return snacks.notifier.Notif[]
local function getHistory()
	return require("snacks").notifier.get_history {
		filter = function(n) return n.level ~= "trace" end,
		reverse = true,
	}
end

---@param idx number|"last"
local function openNotif(idx)
	if idx == "last" then idx = 1 end
	local history = getHistory()
	local notif = history[idx]
	if not notif then
		local msg = "No notifications yet."
		vim.notify(msg, vim.log.levels.TRACE, { title = "Last notification", icon = "󰎟" })
		return
	end
	require("snacks").notifier.hide(notif.id)

	local bufnr = vim.api.nvim_create_buf(false, true)
	local lines = vim.split(notif.msg, "\n")
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	local title = vim.trim((notif.icon or "") .. " " .. (notif.title or ""))
	local height = math.min(#lines + 2, math.ceil(vim.o.lines * 0.75))
	local longestLine = vim.iter(lines):fold(0, function(acc, line) return math.max(acc, #line) end)
	local width = math.min(longestLine + 3, math.ceil(vim.o.columns * 0.75))
	local overflow = #lines + 2 - height -- +2 for border
	local footer = overflow > 0 and (" ↓ %d lines "):format(overflow) or nil

	local levelCapitalized = notif.level:sub(1, 1):upper() .. notif.level:sub(2)
	local highlights = {
		"Normal:SnacksNormal",
		"NormalNC:SnacksNormalNC",
		"FloatBorder:SnacksNotifierBorder" .. levelCapitalized,
		"FloatTitle:SnacksNotifierTitle" .. levelCapitalized,
		"FloatFooter:SnacksNotifierFooter" .. levelCapitalized,
	}

	require("snacks").win {
		position = "float",
		ft = notif.ft or "markdown",
		buf = bufnr,
		height = height,
		width = width,
		title = vim.trim(title) ~= "" and " " .. title .. " " or nil,
		footer = footer,
		footer_pos = footer and "right" or nil,
		wo = {
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

local function allNotifications()
	require("snacks").notifier.hide()
	vim.ui.select(getHistory(), {
		prompt = "󰎟 Notification history",
		format_item = function(item)
			local title = item.title ~= "" and item.title or "(no title)"
			return vim.trim(item.icon .. " " .. title)
		end,
	}, function(_, idx)
		if not idx then return end
		openNotif(idx)
	end)
end

local function messagesAsWin()
	local messages = vim.fn.execute("messages")
	if messages == "" then
		vim.notify("No messages yet.", vim.log.levels.TRACE, { title = ":messages", icon = "󰎟" })
		return
	end
	local lines = vim.split(vim.trim(messages), "\n")
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	require("snacks").win {
		position = "bottom",
		buf = bufnr,
		height = 0.75,
		title = " :messages ",
	}
	-- highlight errors and paths
	vim.api.nvim_buf_call(bufnr, function()
		vim.fn.matchadd("ErrorMsg", [[E\d\+\zs:.*]]) -- errors
		vim.fn.matchadd("ErrorMsg", [[^Error .*]])
		vim.fn.matchadd("DiagnosticInfo", [[[^/]\+\.lua:\d\+\ze:]]) -- filenames
		vim.fn.matchadd("DiagnosticInfo", [[E\d\+]]) -- error numbers differently
		-- `\_.` matches any char, including newline
		vim.fn.matchadd("WarningMsg", [[^stack traceback\_.*\n\t.*]])
	end)
end

--------------------------------------------------------------------------------

local function snacksConfig()
	-- OVERRIDE DEFAULT PRINT FUNCTIONS (similar to `noice.nvim`)
	_G.print = function(...)
		local msg = vim.iter({ ... }):flatten():map(tostring):join(" ")
		local opts = { title = "Print", icon = "󰐪" }
		if msg:find("^%[nvim%-treesitter%]") then
			opts = { icon = "", id = "ts-install", style = "minimal" }
		end
		vim.notify(vim.trim(msg), vim.log.levels.DEBUG, opts)
	end
	---@diagnostic disable-next-line: duplicate-set-field deliberate override
	vim.api.nvim_echo = function(chunks, _, _)
		local msg = vim.iter(chunks):map(function(chunk) return chunk[1] end):join("")
		local opts = { title = "Echo", icon = "" }
		local severity = "DEBUG"
		if msg:lower():find("hunk") then
			msg = msg:gsub("^Hunk (%d+) of (%d+)", "Hunk [%1/%2]") -- [] for markdown highlight
			opts = { icon = "󰊢", id = "gitsigns_nav_hunk", style = "minimal" }
			severity = "TRACE"
		end
		vim.notify(vim.trim(msg), vim.log.levels[severity], opts)
	end
	---@diagnostic disable-next-line: duplicate-set-field deliberate override
	vim.api.nvim_err_writeln = function(msg)
		vim.notify(vim.trim(msg), vim.log.levels.ERROR, { title = "Error" })
	end
	-----------------------------------------------------------------------------

	-- HACK SILENCE SOME MESSAGES by overriding snacks' override
	vim.notify = function(msg, level, opts) ---@diagnostic disable-line: duplicate-set-field
		-- PENDING https://github.com/artempyanykh/marksman/issues/348
		if msg:find("^Client marksman quit with exit code 1") then return end

		-- due to the custom formatter in `typescript.lua` using code-actions
		if msg:find("^No code actions available") then return end

		require("snacks").notifier.notify(msg, level, opts)
	end

	-----------------------------------------------------------------------------
	-- SILENCE "E486: PATTERN NOT FOUND"
	-- (yes, all this is needed to have `cmdheight=0` & avoid the "Press Enter" prompt)

	local function notFoundNotify(query)
		local msg = ("~~%s~~"):format(query) -- add markdown strikethrough
		vim.notify(msg, vim.log.levels.TRACE, { icon = "", style = "minimal" })
	end

	local function nopOnNoMatch(key)
		local query = vim.fn.getreg("/")
		local matches = vim.fn.search(vim.fn.getreg("/"), "ncw") -- [n]o move, w/ [c]ursorword, [w]rap
		if matches == 0 then
			notFoundNotify(query)
			return
		end
		return key -- return and use as `expr` to still trigger `on_key` for `nvim_origami`
	end
	local map = vim.keymap.set
	map("n", "n", function() return nopOnNoMatch("n") end, { desc = "silent n", expr = true })
	map("n", "N", function() return nopOnNoMatch("N") end, { desc = "silent N", expr = true })

	vim.api.nvim_create_autocmd("CmdlineEnter", {
		desc = "User: Increase cmdline-height when in cmdline (silence enter-prompt 1/2)",
		callback = function()
			if vim.fn.getcmdtype() == "/" then vim.opt.cmdheight = 1 end
		end,
	})
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		desc = "User: Decrease cmdline-height after leaving (silence enter-prompt 2/2)",
		callback = function()
			if vim.fn.getcmdtype() ~= "/" then return end
			vim.defer_fn(function()
				vim.opt.cmdheight = 0
				if vim.fn.searchcount().total == 0 then
					vim.opt.hlsearch = false -- no highlight in notification win
					notFoundNotify(vim.fn.getreg("/"))
				end
			end, 1)
		end,
	})
end

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	event = "VeryLazy",
	config = function(_, opts)
		require("snacks").setup(opts)
		snacksConfig()
	end,
	keys = {
		{ "ö", function() require("snacks").words.jump(1, true) end, desc = "󰒕 Next reference" },
		{ "Ö", function() require("snacks").words.jump(-1, true) end, desc = "󰒕 Prev reference" },
		{ "<D-8>", messagesAsWin, mode = { "n", "v", "i" }, desc = "󰎟 :messages" },
		{ "<D-0>", allNotifications, mode = { "n", "v", "i" }, desc = "󰎟 All notifications" },
		-- stylua: ignore
		{ "<Esc>", function() require("snacks").notifier.hide() end, desc = "󰎟 Dismiss notifications" },
		-- stylua: ignore
		{ "<D-9>", function() openNotif("last") end, mode = { "n", "v", "i" }, desc = "󰎟 Last notification" },
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
			keys = {
				q = "close",
				["<Esc>"] = "close",
				["<D-8>"] = "close",
				["<D-9>"] = "close",
				["<D-0>"] = "close",
			},
		},
		notifier = {
			timeout = 7500,
			sort = { "added" }, -- sort only by time
			width = { min = 12, max = 0.5 },
			height = { min = 1, max = 0.5 },
			icons = { error = "", warn = "", info = "", debug = "", trace = "󰓘" },
			top_down = false,
			more_format = " ↓ %d lines ", -- if more lines than height
		},
		styles = {
			notification = {
				border = vim.g.borderStyle,
				wo = { cursorline = false, winblend = 0, wrap = true },
			},
		},
	},
}
