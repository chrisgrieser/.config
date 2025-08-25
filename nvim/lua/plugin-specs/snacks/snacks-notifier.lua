-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md#%EF%B8%8F-config
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
	if #history == 0 then
		local msg = "No notifications yet."
		vim.notify(msg, vim.log.levels.TRACE, { title = "Last notification", icon = "󰎟" })
		return
	end
	local notif = assert(history[idx], "Notification not found.")
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
		ft = notif.ft or "markdown", -- needed for treesitter folding to work
		wo = {
			wrap = notif.ft ~= "lua",
			statuscolumn = " ", -- adds padding
			cursorline = true,
			winfixbuf = true,
			fillchars = "fold: ,eob: ",
			foldmethod = "expr", -- enable folding
			foldexpr = "v:lua.vim.treesitter.foldexpr()",
			winhighlight = "Normal:Normal", -- fix markdown highlighting priority issue
		},
		bo = { modifiable = true },
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

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"folke/snacks.nvim",
	keys = {
		{ "<Esc>", function() Snacks.notifier.hide() end, desc = "󰎟 Dismiss notification" },
		{ "<leader>in", function() openNotif("last") end, desc = "󰎟 Last notification" },
		-- stylua: ignore
		{ "<leader>iN", function() Snacks.picker.notifications() end, desc = "󰎟 Notification history" },
	},
	opts = {
		picker = {
			sources = {
				notifications = {
					formatters = { severity = { level = false } },
					confirm = function(picker)
						local pickerIdx = picker:current().idx
						picker:close()
						openNotif(pickerIdx)
					end,
				},
			},
		},
		---@class snacks.notifier.Config
		notifier = {
			timeout = 7500,
			sort = { "added" }, -- sort only by time
			width = { min = 12, max = 0.45 },
			height = { min = 1, max = 0.65 },
			icons = { error = "󰅚", warn = "", info = "󰋽", debug = "󰃤", trace = "󰓗" },
			top_down = false,
		},
		styles = {
			notification = {
				border = vim.o.winborder,
				focusable = false,
				wo = { winblend = 10, wrap = true },
			},
		},
	},
}
