local inlayHintNs = vim.api.nvim_create_namespace("eol_inlay_hints")
vim.lsp.handlers["textDocument/inlayHint"] = function(err, result, ctx, _)
	if err then
		vim.notify(vim.inspect(err), vim.log.levels.ERROR)
		return
	end
	vim.api.nvim_buf_clear_namespace(ctx.bufnr, inlayHintNs, 0, -1)

	local hintLines = vim.iter(result):fold({}, function(acc, hint)
		local lnum = hint.position.line
		if not acc[lnum] then acc[lnum] = {} end
		local formattedHint = {
			label = hint.label[1].value,
			col = hint.position.character,
		}
		table.insert(acc[lnum], formattedHint)
		return acc
	end)
	vim.notify("👾 hintLines: " .. vim.inspect(hintLines))

	for lnum, hints in ipairs(hintLines) do

		-- local label = hint.label[1].value:gsub("^:", ""):gsub(":$", "")
		-- local kind = hint.kind == 1 and "Type" or "Parameter"
		-- local icon = kind == "Type" and "" or ""
		-- local lnum = hint.position.line
		-- vim.api.nvim_buf_set_extmark(ctx.bufnr, inlayHintNs, lnum, 0, {
		-- 	virt_text = { { icon .. " " .. label, "LspInlayHint" } },
		-- 	virt_text_pos = "eol",
		-- })
	end
end
vim.lsp.inlay_hint.enable(true)
