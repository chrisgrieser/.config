-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md#%EF%B8%8F-config
--------------------------------------------------------------------------------

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
	local moreLines = overflow > 0 and ("↓ %d lines"):format(overflow) or ""
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
		relative = "editor",
		position = "float",
		ft = notif.ft or "markdown",
		buf = bufnr,
		height = height,
		width = width,
		title = vim.trim(title) ~= "" and " " .. title .. " " or nil,
		footer = footer and " " .. footer .. " " or nil,
		footer_pos = footer and "right" or nil,
		wo = {
			winhighlight = table.concat(highlights, ","),
			wrap = true,
			statuscolumn = " ", -- adds padding
			cursorline = true,
			colorcolumn = "",
			winfixbuf = true,
		},
		bo = {
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
	event = "BufReadPre",
	keys = {
		{ "ö", function() require("snacks").words.jump(1, true) end, desc = "󰉚 Next reference" },
		{ "Ö", function() require("snacks").words.jump(-1, true) end, desc = "󰉚 Prev reference" },
		{ "<leader>g?", function() require("snacks").git.blame_line() end, desc = "󰆽 Blame line" },
		{
			"<D-9>",
			function() openNotif("last") end,
			mode = { "n", "v", "i" },
			desc = "󰎟 Last notification",
		},
		{
			"<leader>om",
			function()
				local enabled = require("snacks").dim.enabled
				require("snacks").dim[enabled and "disable" or "enable"]()
			end,
			desc = "󰝟 Mute code",
		},
	},
	opts = {
		dim = {
			scope = { min_size = 4, max_size = 20 },
		},
		indent = {
			char = "│",
			scope = { hl = "Comment" },
			chunk = {
				enabled = false,
				hl = "Comment",
			},
		},
		words = {
			notify_jump = true,
			modes = { "n" },
			debounce = 300,
		},
		win = {
			border = vim.g.borderStyle,
			keys = { q = "close", ["<Esc>"] = "close" },
		},
		notifier = {
			timeout = 7500,
			sort = { "added" }, -- sort only by time
			width = { min = 12, max = 0.5 },
			height = { min = 1, max = 0.5 },
			icons = { error = "󰅚", warn = "", info = "󰋽", debug = "󰃤", trace = "󰓗" },
			top_down = false,
		},
		input = {
			icon = false,
		},
		styles = {
			input = {
				backdrop = true,
				border = vim.g.borderStyle,
				title_pos = "left",
				width = 50,
				row = math.ceil(vim.o.lines / 2) - 3,
				wo = { colorcolumn = "" },
				keys = {
					i_esc = { "<Esc>", { "cmp_close", "stopinsert" }, mode = "i" },
					BS = { "<BS>", "<Nop>", mode = "n" }, -- prevent accidental closing (<BS> -> :bprev)
					CR = { "<CR>", "confirm", mode = "n" },
				},
			},
			notification = {
				border = vim.g.borderStyle,
				wo = { winblend = 0, wrap = true },
			},
			blame_line = {
				width = 0.6,
				height = 0.6,
				border = vim.g.borderStyle,
				title = " 󰆽 Git blame ",
			},
		},
	},
}
