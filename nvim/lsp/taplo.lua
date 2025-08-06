---@type vim.lsp.Config
return {
	on_attach = function(client)
		-- disable formatting in favor of `tombi`
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
