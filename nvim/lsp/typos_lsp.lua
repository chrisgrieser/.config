-- DOCS https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
--------------------------------------------------------------------------------

return {
	init_options = { diagnosticSeverity = "Hint" },
	on_attach = require("config.utils").detachIfObsidianOrIcloud,
}
