-- DOCS https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
--------------------------------------------------------------------------------

return {
	-- Disable formatting in favor of biome
	init_options = { provideFormatter = false, documentRangeFormattingProvider = false },
}
