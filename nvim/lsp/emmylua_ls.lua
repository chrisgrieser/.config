-- DOCS https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	settings = {
		Lua = {
			format = {
				enable = false, -- disable in favor of `stylua`
			},
			diagnostics = {
				disable = {
					"unnecessary-if", -- buggy
				},
			},
			completion = {
				callSnippet = true,
			},
			signature = {
				detailSignatureHelper = true,
			},
			strict = {
				requirePath = true,
				typeCall = true,
			},
		},
	},
}
