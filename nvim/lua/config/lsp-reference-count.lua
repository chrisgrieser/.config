---https://github.com/nvim-telescope/telescope.nvim/blob/a3f17d3baf70df58b9d3544ea30abe52a7a832c2/lua/telescope/builtin/__lsp.lua#L12
function LspReferences()
	local params = vim.lsp.util.make_position_params(0) ---@diagnostic disable-line: missing-parameter
	params.context = { includeDeclaration = false }

	vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, ctx, _)
		if err then
			vim.api.nvim_err_writeln("Error when finding references: " .. err.message)
			return
		end

		local locations = {}
		if result then
			local results = vim.lsp.util.locations_to_items(
				result,
				vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
			)
			locations = vim.F.if_nil(results, {})
		end

		vim.notify(tostring(#locations), logWarn)
	end)
end

keymap("n", "<D-f>", LspReferences)
