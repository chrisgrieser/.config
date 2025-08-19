-- DOCS https://github.com/redhat-developer/yaml-language-server/tree/main#language-server-settings
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	settings = {
		yaml = {
			format = {
				printWidth = 100,
				proseWrap = "always",
			},
		},
	},
}
