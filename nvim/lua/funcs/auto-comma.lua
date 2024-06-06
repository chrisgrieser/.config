vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
			buffer = 0,
			callback = function()
				local node = vim.treesitter.get_node()
				if not (node and node:type() == "table_constructor") then return end

				local currentLine = vim.api.nvim_get_current_line()
				local emptyLine = currentLine:find("^%s*$")
				local alreadyHasComma = currentLine:find(",%s*$")
				if not emptyLine and alreadyHasComma then return end

				vim.api.nvim_set_current_line(currentLine .. ",")
			end,
		})
	end,
})
