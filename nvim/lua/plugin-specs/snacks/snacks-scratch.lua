-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md
--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		{ "<leader>es", function() require("snacks").scratch() end, desc = " Scratch buffer" },
		{ "<leader>eS", function() Snacks.scratch.select() end, desc = " Select scratch" },
	},
	---@type snacks.Config
	opts = {
		scratch = {
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
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"|"shadow"]],
				footer_pos = "right",
				keys = {
					q = false, -- so `q` is available as my comment operator
					["<D-w>"] = "close",
				},
			},
		},
	},
}
