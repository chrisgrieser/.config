return {
	"zk-org/zk-nvim",
	main = "zk",
	lazy = false,
	init = function() vim.env.ZK_NOTEBOOK_DIR = vim.g.notesDir end,
	opts = {
		picker = "snacks_picker",
	},
}
