-- inspect capabilities of current lsp
-- no arg: all LSPs attached to current buffer
-- one arg: name of the LSP
vim.api.nvim_create_user_command("LspCapabilities", function(ctx)
	local filter = ctx.args == "" and { bufnr = vim.api.nvim_get_current_buf() }
		or { name = ctx.args }
	local clients = vim.lsp.get_active_clients(filter)

	local out = {}
	for _, client in pairs(clients) do
		local client_info = client.name:upper() .. "\n" .. vim.inspect(client)
		table.insert(out, client_info)
	end
	local msg = table.concat(out, "\n\n")
	vim.notify(msg)
end, {
	nargs = "?",
	complete = function()
		local clients = vim.tbl_map(
			function(client) return client.name end,
			vim.lsp.get_active_clients()
		)
		table.sort(clients)
		return clients
	end,
})

--------------------------------------------------------------------------------

