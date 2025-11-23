return {
	"kawre/leetcode.nvim",
	lazy = vim.fn.argv(0, -1) ~= "leetcode.nvim", -- start via `nvim "leetcode.nvim"`

	dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
	config = function(_, opts)
		vim.g.whichkeyAddSpec { "<leader>x", group = "󰹂 Leetcode" }
		require("leetcode").setup(opts)

		-- FIX snacks notifications not being replacing
		vim.defer_fn(function()
			local oldNotify = vim.notify
			vim.notify = function(msg, level, o) ---@diagnostic disable-line: duplicate-set-field intentional overwrite
				if not o then o = {} end
				if o.title == "leetcode.nvim" then o.id = "leetcode" end
				oldNotify(msg, level, o)
			end
		end, 1000) -- defer for notification plugin

		-- FIX missing `nowait`
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "leetcode.nvim",
			callback = function(ctx)
				local function set()
					vim.keymap.set("n", "q", vim.cmd.quit, { nowait = true, buffer = ctx.buf })
				end
				vim.defer_fn(set, 100) -- defer to overwrite the leetcode.nvim's keymap
			end,
		})
	end,
	keys = {
		-- https://github.com/kawre/leetcode.nvim#-commands
		{ "<leader>xx", "<cmd>Leet run<CR>", desc = " Run" },
		{ "<leader>xd", "<cmd>Leet desc<CR>", desc = " Toggle problem desc" },
		{ "<leader>xs", "<cmd>Leet submit<CR>", desc = " Submit" },
		{ "<leader>xo", "<cmd>Leet open<CR>", desc = "󰖟 Open in browser" },
		{ "<leader>xp", "<cmd>Leet list difficulty=easy<CR>", desc = " Problem list (easy)" },
		{ "<leader>xr", "<cmd>Leet random difficulty=easy<CR>", desc = " Random problem (easy)" },
		{ "<leader>xh", "<cmd>Leet info<CR>", desc = " Hints & similar problems" },
		{ "<leader>xm", "<cmd>Leet menu<CR>", desc = "󰹯 Leetcode menu" },
	},
	opts = {
		lang = "typescript", -- https://github.com/kawre/leetcode.nvim#lang
		storage = {
			home = vim.g.iCloudSync .. "/leetcode",
		},
		description = {
			position = "left",
			width = "60%",
		},
	},
}
