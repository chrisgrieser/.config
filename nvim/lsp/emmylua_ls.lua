-- DOCS https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	on_attach = function(client)
		-- disable formatting in favor of `stylua`
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	settings = {
		Lua = {
			diagnostics = {
				disable = {
					"unnecessary-if", -- buggy rule
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
