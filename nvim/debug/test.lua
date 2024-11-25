local clients = vim.lsp.get_clients { bufnr = 0 }
local longestName = vim.iter(clients)
	:fold(0, function(acc, client)
		return acc + #client.name
	end)
