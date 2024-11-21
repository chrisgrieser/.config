local s = ("sss"):gsub("f", "1")

local params = vim.lsp.util.make_position_params()
vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result)
	if err then vim.notify(err, vim.log.levels.ERROR, { title = "LSP Hover" }) end
	local text = result.contents.value ---@cast text string

	local urls = {}
	for url in text:gmatch("%l%l%l-://[A-Za-z0-9_%-/.#%%=?&'@+*:]+") do
		table.insert(urls, url)
	end
	if #urls == 0 then
		vim.notify("No URLs found.", nil, { title = "Hover URL", icon = "" })
	elseif #urls > 1 then
		vim.ui.open(urls[1])
	else
		vim.ui.select(urls, { prompt = " Select URL" }, function(url)
			if url then vim.ui.open(url) end
		end)
	end
end)
