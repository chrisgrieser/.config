local bufnr = vim.api.nvim_get_current_buf()
local cursor = vim.api.nvim_win_get_cursor(0)
local bufname = vim.api.nvim_buf_get_name(bufnr)

local params = {
	textDocument = { uri = bufname },
	position = { line = cursor[1] - 1, character = cursor[2] },
	context = { includeDeclaration = true },
}

vim.lsp.buf_request(bufnr, "textDocument/references", params, function(err, result, _, _)
	if err then
		print(tostring(err))
		return
	elseif not result then
		print("no result")
		return
	end
	local reference_count = vim.tbl_count(result) - 1
	print(reference_count)
end)
