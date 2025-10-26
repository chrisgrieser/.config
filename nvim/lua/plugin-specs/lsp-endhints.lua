return {
	"chrisgrieser/nvim-lsp-endhints",
	event = "LspAttach",
	keys = {
		{ "<leader>oh", function() require("lsp-endhints").toggle() end, desc = "󰑀 Endhints" },
	},
	config = function(_, opts)
		-- FIX for emmylua_ls not loading on startup
		vim.defer_fn(function() require("lsp-endhints").setup(opts) end, 100)

		-- disable in insert mode to prevent overlap with `nvim-lsp-signature`
		vim.api.nvim_create_autocmd("InsertEnter", {
			callback = function() vim.lsp.inlay_hint.enable(false, { bufnr = 0 }) end,
		})
		vim.api.nvim_create_autocmd("InsertLeave", {
			callback = function() vim.lsp.inlay_hint.enable(true, { bufnr = 0 }) end,
		})
	end,
}
