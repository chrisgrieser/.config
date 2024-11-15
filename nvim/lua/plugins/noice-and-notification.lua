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
	event = "VeryLazy",
	keys = {
		-- stylua: ignore start
		{ "<Esc>", function() require("snacks").notifier.hide() end, desc = "󰎟 Dismiss notifications" },
		{ "<D-0>", function() require("snacks").notifier.show_history() end, desc = "󰎟 Show notification history" },
		{ "ö", function() require("snacks").words.jump(1, true) end, desc = "󰒕 Next reference" },
		{ "Ö", function() require("snacks").words.jump(-1, true) end, desc = "󰒕 Prev reference" },
		-- stylua: ignore end
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
			width = { min = 20, max = 0.45 },
			height = { min = 1, max = 0.4 },
			icons = { error = "", warn = "", info = "", debug = "", trace = "󰓘" },
			top_down = false,
		},
		styles = {
			notification = {
				border = vim.g.borderStyle,
				wo = { wrap = true, winblend = 0 },
			},
			["notification.history"] = {
				border = vim.g.borderStyle,
				width = 0.8,
				height = 0.8,
				keys = { q = "close", ["<Esc>"] = "close", ["<D-0>"] = "close" },
			},
		},
	},
}
