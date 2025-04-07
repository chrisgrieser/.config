-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md#%EF%B8%8F-config
--------------------------------------------------------------------------------
---@module "snacks"
--------------------------------------------------------------------------------

---@param idx number|"last"
local function openNotif(idx)
	-- CONFIG
	local maxWidth = 0.85
	local maxHeight = 0.85

	-- get notification
	if idx == "last" then idx = 1 end
	local history = Snacks.notifier.get_history {
		filter = function(notif) return notif.level ~= "trace" end,
		reverse = true,
	}
	local notif = history[idx]
	if not notif then
		local msg = "No notifications yet."
		vim.notify(msg, vim.log.levels.TRACE, { title = "Last notification", icon = "󰎟" })
		return
	end
	Snacks.notifier.hide(notif.id)

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
	local moreLines = overflow > 0 and ("↓ %d lines"):format(overflow) or ""
	local indexStr = ("(%d/%d)"):format(idx, #history)
	local footer = vim.trim(indexStr .. "   " .. moreLines)

	local levelCapitalized = notif.level:sub(1, 1):upper() .. notif.level:sub(2)
	local highlights = {
		"Normal:SnacksNormal",
		"NormalNC:SnacksNormalNC",
		"FloatBorder:SnacksNotifierBorder" .. levelCapitalized,
		"FloatTitle:SnacksNotifierTitle" .. levelCapitalized,
		"FloatFooter:SnacksNotifierFooter" .. levelCapitalized,
	}

	-- create win with snacks API
	Snacks.win {
		relative = "editor",
		position = "float",
		buf = bufnr,
		height = height,
		width = width,
		title = vim.trim(title) ~= "" and " " .. title .. " " or nil,
		footer = footer and " " .. footer .. " " or nil,
		footer_pos = footer and "right" or nil,
		border = vim.o.winborder --[[@as "rounded"|"single"|"double"]],
		wo = {
			winhighlight = table.concat(highlights, ","),
			wrap = true,
			statuscolumn = " ", -- adds padding
			cursorline = true,
			colorcolumn = "",
			winfixbuf = true,
			fillchars = "fold: ",
		},
		bo = {
			ft = notif.ft or "markdown", -- not using `snacks_notif` so treesitter attached
			modifiable = false,
		},
		keys = {
			["<D-9>"] = "close", -- same key that was used to open it
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
	"folke/snacks.nvim",
	config = function(_, opts)
		require("snacks").setup(opts)

		-- ignore certain notifications
		---@diagnostic disable-next-line: duplicate-set-field intentional overwrite
		vim.notify = function(msg, ...)
			local ignore = msg == "No code actions available"
				or msg:find("^Client marksman quit with exit code 1 and signal 0.")
			if ignore then return end
			Snacks.notifier(msg, ...)
		end

		-- disable default keymaps to make the `?` help overview less cluttered
		require("snacks.picker.config.defaults").defaults.win.input.keys = {}
	end,
	keys = {
		{ "<Esc>", function() Snacks.notifier.hide() end, desc = "󰎟 Dismiss notification" },
		{ "<D-9>", function() openNotif("last") end, desc = "󰎟 Last notification" },
		{
			"<D-0>",
			function() Snacks.notifier.show_history() end,
			desc = "󰎟 Notification history",
		},
	},
	opts = {
		---@class snacks.notifier.Config
		notifier = {
			timeout = 7500,
			sort = { "added" }, -- sort only by time
			width = { min = 12, max = 0.45 },
			height = { min = 1, max = 0.45 },
			icons = { error = "󰅚", warn = "", info = "󰋽", debug = "󰃤", trace = "󰓗" },
			top_down = false,
		},
		styles = {
			notification = {
				border = vim.o.winborder,
				focusable = false,
				wo = { winblend = 0, wrap = true },
			},
			notification_history = {
				border = vim.o.winborder,
				position = "bottom",
				height = 0.8,
			},
		},
	},
}
