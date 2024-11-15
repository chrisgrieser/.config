vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Highlight filepaths and error codes in noice/snacks notifications.",
	pattern = { "noice", "snacks_notif" },
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
	enabled = false,
	event = "VeryLazy",
	keys = {
		-- stylua: ignore start
		{ "<Esc>", function() require("snacks").notifier.hide() end, desc = "󰎟 Dismiss notifications" },
		{ "ö", function() require("snacks").words.jump(1, true) end, desc = "󰒕 Next reference" },
		{ "Ö", function() require("snacks").words.jump(-1, true) end, desc = "󰒕 Prev reference" },
		-- stylua: ignore end
		{
			"<D-0>",
			function()
				local lines = {}
				for _, notif in pairs(require("snacks").notifier.get_history()) do
					local msg = vim.split(notif.msg, "\n")
					msg[1] = "[" .. notif.title .. "] " .. msg[1]
					vim.list_extend(lines, msg)
				end
				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
				require("snacks").win {
					position = "bottom",
					ft = "markdown",
					buf = bufnr,
					height = 0.5,
				}
			end,
			desc = "󰎟 Notification history",
		},
		{
			"<D-9>",
			function()
				local history = require("snacks").notifier.get_history()
				local last = history[#history]
				local lines = vim.split(last.msg, "\n")
				table.insert(lines, 1, "[" .. last.title .. "]")
				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
				require("snacks").win {
					position = "float",
					ft = "markdown",
					buf = bufnr,
					height = 0.75,
					width = 0.75,
					title = " 󰎟 Last notification ",
					title_pos = "center",
				}
			end,
			desc = "󰎟 Last notification",
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
