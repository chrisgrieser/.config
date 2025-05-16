-- DOCS https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
--------------------------------------------------------------------------------

return {
	on_attach = require("config.utils").detachIfObsidianOrIcloud,
	init_options = {
		diagnosticSeverity = "Hint",
		config = "~/.config/+ linter-configs/global-typos-config.toml"
	},
}
