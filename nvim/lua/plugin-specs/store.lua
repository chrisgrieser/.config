return {
	"alex-popov-tech/store.nvim",
	cmd = "Store",
	keys = {
		{ "<leader>ps", vim.cmd.Store, desc = "Open Plugin Store" },
	},
	opts = {
		width = 0.99,
		height = 0.99,
		proportions = { list = 0.3, preview = 0.7 },
		modal = { border = vim.o.winborder },
	},
}
