vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype ~= "" then return end
		vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
			buffer = ctx.buf,
			group = vim.api.nvim_create_augroup("AutoComma", {}),
			callback = function()
				local node = vim.treesitter.get_node()
				if not (node and node:type() == "table_constructor") then return end

				local line = vim.api.nvim_get_current_line()
				if line:find("^%s*[^,%s{}-]$") or line:find("^%s*{}$") then
					vim.api.nvim_set_current_line(line .. ",")
				end
			end,
		})
	end,
})
