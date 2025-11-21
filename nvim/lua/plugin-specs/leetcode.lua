return {
	"kawre/leetcode.nvim",
	lazy = vim.fn.argv(0, -1) ~= "leetcode.nvim", -- start via `nvim "leetcode.nvim"`

	dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
	config = function(_, opts)
		vim.g.whichkeyAddSpec { "<leader>x", group = "󰹂 Leetcode" }
		require("leetcode").setup(opts)
	end,
	keys = {
		-- https://github.com/kawre/leetcode.nvim#-commands
		{ "<leader>xx", "<cmd>Leet run<CR>", desc = " Run" },
		{ "<leader>xd", "<cmd>Leet desc<CR>", desc = " Toggle problem desc" },
		{ "<leader>xs", "<cmd>Leet submit<CR>", desc = " Submit" },
		{ "<leader>xo", "<cmd>Leet open<CR>", desc = "󰖟 Open in browser" },
		{ "<leader>xp", "<cmd>Leet list difficulty=easy<CR>", desc = " Problem list" },
		{ "<leader>xh", "<cmd>Leet info<CR>", desc = " Hints & similar problems" },
		{ "<leader>xm", "<cmd>Leet menu<CR>", desc = "󰹯 Leetcode menu" },
	},
	opts = {
		lang = "javascript", -- https://github.com/kawre/leetcode.nvim#lang
		storage = {
			home = vim.g.iCloudSync .. "/leetcode",
		},
		description = {
			position = "left",
			width = "50%",
		},
	},
}
