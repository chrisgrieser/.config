local originalInlayHintHandler = vim.lsp.handlers["textDocument/inlayHint"]
vim.lsp.handlers["textDocument/inlayHint"] = function(err, result, ctx, config)
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	result = vim.iter(result)
		:filter(function(hint) return hint.position.line + 1 == row end)
		:totable()
	originalInlayHintHandler(err, result, ctx, config)
end
vim.lsp.inlay_hint.enable(false)
