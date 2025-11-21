return {
	"kawre/leetcode.nvim",
	cmd = "Leet",
	lazy = false,
	dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
	init = function() vim.g.whichkeyAddSpec { "<leader>x", group = "󰹂 Leetcode" } end,
	keys = {
		-- https://github.com/kawre/leetcode.nvim#-commands
		{ "<leader>x<CR>", "<cmd>Leet run<CR>", desc = " Run" },
		{ "<leader>xs", "<cmd>Leet submit<CR>", desc = " Submit" },
		{ "<leader>xo", "<cmd>Leet open<CR>", desc = "󰖟 Open in browser" },
		{ "<leader>xy", "<cmd>Leet yank<CR>", desc = "󰅍 Yank code section" },
		{ "<leader>xp", "<cmd>Leet list difficulty=easy<CR>", desc = " Problem list" },
		{ "<leader>xh", "<cmd>Leet info<CR>", desc = " Hints & similar" },
		{ "<leader>xx", "<cmd>Leet desc<CR>", desc = " Toggle sidebar" },
	},
	opts = {
		lang = "javascript", -- https://github.com/kawre/leetcode.nvim#lang
		storage = {
			home = vim.g.iCloudSync .. "/leetcode",
		},
		description = {
			position = "left",
			width = "40%",
			show_stats = true,
		},
	},
}
