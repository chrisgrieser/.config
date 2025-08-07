-- DOCS https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	on_attach = require("config.utils").detachIfObsidianOrIcloud,
	init_options = {
		diagnosticSeverity = "Hint",
		config = vim.fn.stdpath("config") .. "/lsp/typos_lsp_global_config.toml",
	},
}
