local function foo()
	local a = "hello" + "world"
	local b = "hello" + "world"
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("luaDiagnostics", { clear = true }),
	pattern = "lua",
	callback = function(ctx)
		local ns = vim.api.nvim_create_namespace("luaDiagnostics")

		---@type vim.Diagnostic[]
		local diags = {}
		local bufLines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)

		for lnum = 1, #bufLines do
			local line = bufLines[lnum]
			local startCol, endCol = line:find([[".*" ?%+? ".*"]])
			if not (startCol and endCol) then
				startCol, endCol = line:find([['.*' ?%+? '.*']])
			end
			if startCol and endCol then
				table.insert(diags, {
					lnum = lnum - 1,
					col = startCol,
					end_col = endCol,
					message = "Use `..` instead of `+` to concatenate strings in lua.",
					severity = vim.diagnostic.severity.WARN,
					source = "mySource",
				})
			end
		end
		vim.notify("👾 #diags: " .. vim.inspect(#diags))
		if #diags > 0 then vim.diagnostic.set(ns, ctx.buf, diags) end
	end,
})
