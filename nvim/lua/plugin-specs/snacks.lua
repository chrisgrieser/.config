---@module "snacks"

local border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"|"shadow"]]

return {
	"folke/snacks.nvim",
	event = "BufReadPre",
	keys = {
		{ "ö", function() Snacks.words.jump(1, true) end, desc = "󰉚 Next reference" },
		{ "Ö", function() Snacks.words.jump(-1, true) end, desc = "󰉚 Prev reference" },
		{ "<leader>g?", function() Snacks.git.blame_line() end, desc = "󰆽 Blame line" },
		{ "<leader>es", function() Snacks.scratch() end, desc = " Scratch buffer" },
		{ "<leader>el", function() Snacks.scratch.select() end, desc = " Select scratch buffer" },
	},
	---@type snacks.Config
	opts = {
		scratch = {
			-- https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md
			root = vim.g.icloudSync .. "/scratch",
			filekey = { cwd = false, branch = false, count = false }, -- one scratch per filetype
			win = {
				relative = "editor",
				-- position = "right",
				width = 75,
				height = 20,
				wo = { signcolumn = "yes:1" },
				border = border,
				footer_pos = "right",
				keys = {},
			},
		},
		words = {
			notify_jump = true,
			modes = { "n" },
			debounce = 300,
		},
		input = {
			icon = "",
			win = {
				relative = "editor",
				backdrop = 60,
				border = border,
				title_pos = "left",
				width = 50,
				row = math.ceil(vim.o.lines / 2) - 3,
			},
		},
		indent = {
			char = "│",
			scope = { hl = "Comment" },
			chunk = {
				enabled = false,
				hl = "Comment",
			},
		},
		blame_line = {
			win = {
				relative = "cursor",
				width = 0.6,
				height = 0.6,
				border = border,
				title = " 󰆽 Git blame ",
			},
		},
	},
}
