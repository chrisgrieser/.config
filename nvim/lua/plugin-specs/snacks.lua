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
		{ "<leader>eS", function() Snacks.scratch.select() end, desc = " Select scratch" },
	},
	---@type snacks.Config
	opts = {
		scratch = {
			-- https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md
			root = vim.g.icloudSync .. "/scratch",
			filekey = {
				count = true, -- allows count to create multiple scratch buffers
				cwd = false, -- otherwise only one scratch per filetype
				branch = false,
			},
			win = {
				relative = "editor",
				position = "float", -- or "right"
				width = 80,
				height = 25,
				wo = { signcolumn = "yes:1" },
				border = border,
				footer_pos = "right",
				keys = { q = false, ["<D-w>"] = "close" }, -- so we can comment with `q`
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
			animate = {
				-- slower for more dramatic effect
				duration = { steps = 200, total = 1000 }
			}
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
