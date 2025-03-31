return {
	"folke/snacks.nvim",
	event = "BufReadPre",
	keys = {
		{ "ö", function() require("snacks").words.jump(1, true) end, desc = "󰉚 Next reference" },
		{ "Ö", function() require("snacks").words.jump(-1, true) end, desc = "󰉚 Prev reference" },
		{ "<leader>g?", function() require("snacks").git.blame_line() end, desc = "󰆽 Blame line" },
	},
	opts = {
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
		input = {
			icon = false,
		},
		win = {
			border = vim.o.winborder,
		},
		styles = {
			input = {
				backdrop = true,
				border = vim.o.winborder,
				title_pos = "left",
				width = 50,
				row = math.ceil(vim.o.lines / 2) - 3,
			},
			blame_line = {
				backdrop = true,
				width = 0.6,
				height = 0.6,
				border = vim.o.winborder,
				title = " 󰆽 Git blame ",
			},
		},
	},
}
