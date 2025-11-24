-- DOCS https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	init_options = {
		diagnosticSeverity = "Hint",
		config = vim.fn.stdpath("config") .. "/lsp/typos_lsp_global_config.toml",
	},
}
