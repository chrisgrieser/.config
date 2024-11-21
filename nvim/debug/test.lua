("sss"):gsub("f", "1")

local params = vim.lsp.util.make_position_params()
vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result)
	if err then vim.notify(err, vim.log.levels.ERROR, { title = "LSP Hover" }) end

	local url = result.contents.value:match("%l%l%l-://[A-Za-z0-9_%-/.#%%=?&'@+*:]+")
	vim.notify(--[[🖨️]] vim.inspect(url), nil, { title = "🖨️ url", ft = "lua" })
end)
