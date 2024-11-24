-- INFO Commands for displaying the `snacks.nvim` notification history
--------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------

function M.full()
	-- get history
	local skipTraceLevel = function(n) return n.level ~= "trace" end
	local history = require("snacks").notifier.get_history { filter = skipTraceLevel }
	if #history == 0 then
		local opts = { title = "Notification history", icon = "󰎟" }
		vim.notify("No notifications yet.", vim.log.levels.TRACE, opts)
		return
	end
	require("snacks").notifier.hide() -- dismiss all currently open notices

	-- set buffer text
	local notifyData = {}
	local lines = vim.iter(history):rev():fold({}, function(acc, n)
		local msg = vim.split(n.msg, "\n")
		local title = (n.title and n.title ~= "") and n.title or (n.icon or "ﱢ")
		notifyData[#acc] = { title = title, level = n.level }
		return vim.list_extend(acc, msg)
	end)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

	-- add titles
	local ns = vim.api.nvim_create_namespace("snacks-history")
	for lnum, data in pairs(notifyData) do
		local levelCapitalized = data.level:sub(1, 1):upper() .. data.level:sub(2)
		local hlgroup = "SnacksNotifierTitle" .. levelCapitalized
		vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
			virt_text = { { data.title .. " ", hlgroup } },
			virt_text_pos = "inline",
		})
	end

	-- create win
	require("snacks").win {
		position = "bottom",
		buf = bufnr,
		height = 0.6,
		keys = { ["<D-0>"] = "close" }, -- close win with key that opened it
	}
end

function M.last()
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

function M.messages()
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
		vim.fn.matchadd("ErrorMsg", [[E\d\+:\zs.*]]) -- errors
		vim.fn.matchadd("ErrorMsg", [[^Error .*]])
		vim.fn.matchadd("DiagnosticInfo", [[[^/]\+\.lua:\d\+\ze:]]) -- filenames
		-- vim.fn.matchadd("DiagnosticInfo", [[E\d\+]]) -- error numbers differently
		-- `\_.` matches any char, including newline
		vim.fn.matchadd("WarningMsg", [[^stack traceback\_.*\n\t.*]])
	end)
end

--------------------------------------------------------------------------------
return M
