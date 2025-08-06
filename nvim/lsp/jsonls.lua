-- DOCS https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	-- Disable formatting in favor of biome
	init_options = { provideFormatter = false, documentRangeFormattingProvider = false },
}
