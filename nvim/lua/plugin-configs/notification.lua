-- DOCS Snacks.notifier
-- https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md#%EF%B8%8F-config
--------------------------------------------------------------------------

local function last()
	local skipTraceLevel = function(n) return n.level ~= "trace" end
	local history = require("snacks").notifier.get_history { filter = skipTraceLevel }
	local last = history[#history]
	if not last then
		local opts = { title = "Last notification", icon = "󰎟" }
		vim.notify("No notifications yet.", vim.log.levels.TRACE, opts)
		return
	end
	require("snacks").notifier.hide(last.id) -- when opening last notif, dismiss it

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(last.msg, "\n"))
	local title = vim.trim((last.icon or "") .. " " .. (last.title or ""))
	require("snacks").win {
		position = "float",
		ft = last.ft or "markdown",
		buf = bufnr,
		height = 0.75,
		width = 0.75,
		title = vim.trim(title) ~= "" and " " .. title .. " " or nil,
		keys = { ["<D-9>"] = "close" }, -- close win with key that opened it
	}
end

local function messages()
	local messages = vim.fn.execute("messages")
	if messages == "" then
		vim.notify("No messages yet.", vim.log.levels.TRACE, { title = ":messages", icon = "󰎟" })
		return
	end
	local lines = vim.split(vim.trim(messages), "\n")
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	require("snacks").win {
		position = "float",
		buf = bufnr,
		height = 0.75,
		width = 0.75,
		title = " :messages ",
		keys = { ["<D-8>"] = "close" }, -- close win with key that opened it
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
	vim.notify = function(msg, ...) ---@diagnostic disable-line: duplicate-set-field
		-- PENDING https://github.com/artempyanykh/marksman/issues/348
		if msg:find("^Client marksman quit with exit code 1") then return end

		-- due to the custom formatter in `typescript.lua` using code-actions
		if msg:find("^No code actions available") then return end

		require("snacks").notifier.notify(msg, ...)
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
		return key -- return and use as `expr` to keep correct `on_key` trigger for `nvim_origami`
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
		{ "<Esc>", function() require("snacks").notifier.hide() end, desc = "󰎟 Dismiss notices" },
		{ "<D-8>", messages, mode = { "n", "x", "i" }, desc = "󰎟 :messages" },
		{ "<D-9>", last, mode = { "n", "x", "i" }, desc = "󰎟 Last notification" },
		{
			"<D-0>",
			function()
				local skipTraceLevel = function(n) return n.level ~= "trace" end
				require("snacks").notifier.show_history { filter = skipTraceLevel }
			end,
			mode = { "n", "x", "i" },
			desc = "󰎟 Notification history",
		},
	},
	opts = {
		words = {
			notify_jump = true,
			modes = { "n" },
			debounce = 300,
		},
		win = {
			keys = { q = "close", ["<Esc>"] = "close" },
			border = vim.g.borderStyle,
			bo = { modifiable = false },
			wo = { cursorline = true, colorcolumn = "", winfixbuf = true, wrap = true },
		},
		notifier = {
			timeout = 6000,
			sort = { "added" }, -- sort only by time
			width = { min = 12, max = 0.5 },
			height = { min = 1, max = 0.5 },
			icons = { error = "", warn = "", info = "", debug = "", trace = "󰓘" },
			top_down = false,
		},
		styles = {
			notification = {
				border = vim.g.borderStyle,
				wo = { wrap = true, winblend = 0, cursorline = false },
			},
		},
	},
}
