---@type vim.lsp.Config
return {
	-- disable code lens since the number of heading references is not useful info
	on_attach = function(client, _bufnr)
		client.server_capabilities.codeLensProvider = {}
	end,
}
