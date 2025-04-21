-- DOCS
-- https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
-- https://github.com/microsoft/vscode-css-languageservice/blob/main/src/services/lintRules.ts
--------------------------------------------------------------------------------

return {
	-- using `biome` instead (this key overrides `settings.format.enable = true`)
	init_options = { provideFormatter = false },

	settings = {
		css = {
			lint = {
				vendorPrefix = "ignore", -- needed for scrollbars
				duplicateProperties = "warning",
				zeroUnits = "warning",
			},
		},
	},
}
