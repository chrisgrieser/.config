-- DOCS https://github.com/redhat-developer/yaml-language-server/tree/main#language-server-settings
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	---@type lspconfig.settings.yamlls
	settings = {
		yaml = {
			format = {
				printWidth = 100,
				proseWrap = "always",
			},
		},
	},
}
