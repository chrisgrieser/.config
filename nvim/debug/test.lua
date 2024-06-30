local pluginName = "EolInlayHints"
local inlayHintNs = vim.api.nvim_create_namespace(pluginName)
--------------------------------------------------------------------------------

vim.lsp.handlers["textDocument/inlayHint"] = function(err, result, ctx, _)
	local config = {
		icons = { type = " ", parameter = "󰏪 " },
		label = { separator = " ", padding = true },
	}

	if err then
		vim.notify(vim.inspect(err), vim.log.levels.ERROR)
		return
	end
	vim.api.nvim_buf_clear_namespace(ctx.bufnr, inlayHintNs, 0, -1)

	-- Collect all hints for each line. This is so we can sort them by column in
	-- the loop below, to ensure the hints are displayed in the correct order.
	local hintLines = vim.iter(result):fold({}, function(acc, hint)
		local lnum = hint.position.line
		local label = hint.label[1].value:gsub("^:", ""):gsub(":$", "")
		local icon = hint.kind == 1 and config.icons.type or config.icons.parameter
		local formattedHint = {
			label = icon .. label,
			col = hint.position.character,
		}
		if not acc[lnum] then acc[lnum] = {} end
		table.insert(acc[lnum], formattedHint)
		return acc
	end)

	for lnum, hints in pairs(hintLines) do
		table.sort(hints, function(a, b) return a.col < b.col end)
		local allLabels = vim.iter(hints)
			:map(function(hint) return hint.label end)
			:join(config.label.separator)
		if config.label.padding then allLabels = " " .. allLabels .. " " end

		vim.api.nvim_buf_set_extmark(ctx.bufnr, inlayHintNs, lnum, 0, {
			virt_text = { { allLabels, "LspInlayHint" } },
			virt_text_pos = "eol",
		})
	end
end

--------------------------------------------------------------------------------

-- lsp attach/detach
vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
	group = vim.api.nvim_create_augroup(pluginName, { clear = true }),
	callback = function(ctx)
		local enabled = ctx.event == "LspAttach"
		vim.lsp.inlay_hint.enable(enabled, { bufnr = ctx.buf })
		if enabled then
			vim.notify("inlay hints enabled")
		end
	end,
})

-- initialize in already open buffers
vim.iter(vim.api.nvim_list_bufs())
	:filter(function(bufnr) return vim.api.nvim_buf_is_loaded(bufnr) end)
	:each(function(bufnr) vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end)
