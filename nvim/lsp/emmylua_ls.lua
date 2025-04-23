-- DOCS https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md
--------------------------------------------------------------------------------

return {
	on_attach = function(client)
		-- disable formatting in favor of `stylua`
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		-- FIX folds too much on kind `comment`
		client.server_capabilities.foldingRangeProvider = false
	end,
	settings = {
		Lua = {
			completion = { postfix = "." }, -- useful for `table.insert` and the like
			signature = { detailSignatureHelper = true },
			diagnostics = {
				disable = {
					"type-not-found", -- PENDING https://github.com/folke/lazydev.nvim/issues/86
				},
			},
			strict = {
				requirePath = true,
				typeCall = true,
				arrayIndex = false, -- too strict, checks for sparse arrays everywhere
			},
		},
	},
}
