-- DOCS https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md
--------------------------------------------------------------------------------

return {
	on_attach = function(client)
		-- disable formatting in favor of `stylua`
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	init_options = {
		Lua = {
			hint = {
				enable = false,
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
