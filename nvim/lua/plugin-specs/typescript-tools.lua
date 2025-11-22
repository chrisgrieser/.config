return {
	"pmizio/typescript-tools.nvim",
	requires = "nvim-lua/plenary.nvim",
	ft = { "typescript", "javascript" },
	config = function(_, opts)
		vim.lsp.enable("ts_ls", false) -- wrapper for it
		require("typescript-tools").setup(opts)
	end,
	opts = {
		settings = {
			code_lens = "all",
		}
	},
}
