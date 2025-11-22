return {
	"pmizio/typescript-tools.nvim",
	requires = "nvim-lua/plenary.nvim",
	ft = { "typescript", "javascript" },
	config = function(_, opts)
		vim.lsp.enable("ts_ls", false) -- wrapper for tsserver, thus disabling here
		local tsConfig = vim.lsp.config.ts_ls
		opts.root_markers = tsConfig.root_markers
		opts.root_dir = tsConfig.root_dir
		opts.settings = tsConfig.settings
		opts.on_attach = tsConfig.on_attach

		opts.settings.code_lens = "all"
		opts.settings.disable_member_code_lens = false
		require("typescript-tools").setup(opts)
	end,
}
