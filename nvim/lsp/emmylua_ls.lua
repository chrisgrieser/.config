-- DOCS https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md
--------------------------------------------------------------------------------
-- TODO replace even lazydev.nvim? https://www.reddit.com/r/neovim/comments/1mdtr4g/emmylua_ls_is_supersnappy/

return {
	on_attach = function(client)
		-- disable formatting in favor of `stylua`
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	settings = {
		Lua = {
			completion = { postfix = "." }, -- useful for `table.insert` and the like
			signature = { detailSignatureHelper = true },
			strict = {
				requirePath = true,
				typeCall = true,
				arrayIndex = false, -- too strict, checks for sparse arrays everywhere
			},
		},
	},
}
