local function fff() print("hi") end

vim.lsp.buf.document_symbol {
	on_list = function(items)
		vim.notify(vim.inspect(items))
	end,
}
