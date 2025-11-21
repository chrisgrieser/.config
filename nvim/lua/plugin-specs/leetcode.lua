return {
	"kawre/leetcode.nvim",
	cmd = "Leet",
	dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
	opts = {
		lang = "javascript", -- https://github.com/kawre/leetcode.nvim?tab=readme-ov-file#lang
		description = {
			show_stats = false,
		},
		plugins = {
			non_standalone = true,
		},
		keys = {
			toggle = { "q" },
			confirm = { "<S-CR>" },

			reset_testcases = "r",
			use_testcase = "U",
			focus_testcases = "H",
			focus_result = "L",
		},
		theme = {
			["normal"] = { fg = "#EA4AAA" },
		},
	},
}
