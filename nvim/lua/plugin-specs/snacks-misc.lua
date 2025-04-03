-- DOCS https://github.com/folke/snacks.nvim#-features
--------------------------------------------------------------------------------
---@module "snacks"
--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	event = "BufReadPre",
	keys = {
		{ "ö", function() Snacks.words.jump(1, true) end, desc = "󰉚 Next reference" },
		{ "Ö", function() Snacks.words.jump(-1, true) end, desc = "󰉚 Prev reference" },
		{ "<leader>g?", function() Snacks.git.blame_line() end, desc = "󰆽 Blame line" },
	},
	---@type snacks.Config
	opts = {
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
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
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
			animate = {
				-- slower for more dramatic effect :D
				duration = { steps = 200, total = 1000 }
			}
		},
		blame_line = {
			win = {
				relative = "cursor",
				width = 0.6,
				height = 0.6,
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
				title = " 󰆽 Git blame ",
			},
		},
	},
}
