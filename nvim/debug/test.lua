local function fff() print("hi") end

vim.lsp.buf.document_symbol {
	on_list = function(response)
		vim.notify("🪚 response: " .. vim.inspect(response))
		local funcsObjs = vim.tbl_filter(function(item) return item.kind == "Function" end, response.items)
		local funcNames = vim.tbl_map(function(item)
			return item.text:gsub("^%[Function%] ", "")
		end, funcsObjs)
	end,
}
	
