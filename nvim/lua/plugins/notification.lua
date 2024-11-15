vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Highlight filepaths and error codes in noice/snacks notifications.",
	pattern = { "noice", "snacks_notif", "snacks_win" },
	callback = function(ctx)
		vim.defer_fn(function()
			vim.api.nvim_buf_call(ctx.buf, function()
				vim.fn.matchadd("WarningMsg", [[[^/]\+\.lua:\d\+\ze:]])
				vim.fn.matchadd("WarningMsg", [[E\d\+]])
			end)
		end, 1)
	end,
})

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	event = "VeryLazy",
	keys = {
		-- stylua: ignore start
		{ "<Esc>", function() require("snacks").notifier.hide() end, desc = "󰎟 Dismiss notifications" },
		{ "ö", function() require("snacks").words.jump(1, true) end, desc = "󰒕 Next reference" },
		{ "Ö", function() require("snacks").words.jump(-1, true) end, desc = "󰒕 Prev reference" },
		-- stylua: ignore end
		{
			desc = "󰎟 Notification history",
			"<D-0>",
			function()
				local lines = {}
				vim
					.iter(require("snacks").notifier.get_history())
					:rev() -- last notification on top
					:each(function(notif)
						local msg = vim.split(notif.msg, "\n")
						local icon = notif.level ~= "info" and notif.icon .. " " or ""
						msg[1] = "[" .. icon .. notif.title .. "] " .. msg[1]
						vim.list_extend(lines, msg)
					end)
				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
				require("snacks").win {
					position = "bottom",
					ft = "markdown",
					buf = bufnr,
					height = 0.5,
				}
			end,
		},
		{
			desc = "󰎟 Last notification",
			"<D-9>",
			function()
				local history = require("snacks").notifier.get_history()
				local last = history[#history]
				if not last then return end
				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(last.msg, "\n"))
				local title = vim.trim((last.icon or "") .. " " .. (last.title or ""))
				require("snacks").win {
					position = "float",
					ft = "markdown",
					buf = bufnr,
					height = 0.75,
					width = 0.75,
					title = vim.trim(title) ~= "" and title or nil,
				}
			end,
		},
	},
	opts = {
		words = {
			notify_jump = true,
			modes = { "n" },
			debounce = 300,
		},
		-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md#%EF%B8%8F-config
		notifier = {
			timeout = 6000,
			width = { min = 20, max = 0.5 },
			height = { min = 1, max = 0.4 },
			icons = { error = "", warn = "", info = "", debug = "", trace = "󰓘" },
			top_down = false,
		},
		win = {
			keys = { q = "close", ["<Esc>"] = "close", ["<D-0>"] = "close", ["<D-9>"] = "close" },
			border = vim.g.borderStyle,
		},
		styles = {
			notification = {
				border = vim.g.borderStyle,
				wo = { wrap = true, winblend = 0 },
			},
		},
	},
}
