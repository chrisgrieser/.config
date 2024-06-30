local originalInlayHintHandler = vim.lsp.handlers["textDocument/inlayHint"]
local ns = vim.api.nvim_create_namespace("eol_inlay_hints")
vim.lsp.handlers["textDocument/inlayHint"] = function(err, result, ctx, config)
	vim.api.nvim_buf_clear_namespace(ctx.bufnr, ns, 0, -1)
	local currentFile = vim.uri_from_bufnr(ctx.bufnr)
	vim.iter(result)
		:filter(function(hint) return hint.file == currentFile end)
		:map(function(hint)
			local label = hint.label[1].value
			local type = hint.type == 1 and "Type" or "Parameter"
			local lnum = hint.label[1].location.range.start.line
			if lnum == 0 or lnum > vim.api.nvim_buf_line_count(ctx.bufnr) then
				vim.notify("👾 hint: " .. vim.inspect(hint))
				return
			end
			return { lnum = lnum, label = label, type = type }
		end)
		:each(function(hint)
			vim.notify("👾 hint: " .. vim.inspect(hint))
			vim.api.nvim_buf_set_extmark(ctx.bufnr, ns, hint.lnum, 0, {
				virt_text = { { hint.label, "LspInlayHint" } },
				virt_text_pos = "eol",
			})
		end)
	-- vim.notify_once("👾 hints: " .. vim.inspect(hints))

	-- originalInlayHintHandler(err, result, ctx, config)
end
vim.lsp.inlay_hint.enable(true)
