-- Sends a LSP rename request and optionally displays a message to the user showing
-- how many instances were renamed in how many files
local function perform_lsp_rename(new_name)
	local params = vim.lsp.util.make_position_params()
	params.newName = new_name

	vim.lsp.buf_request(0, "textDocument/rename", params, function(err, result, ctx, _)
		if err and err.message then
			vim.notify("Error while renaming: " .. err.message, vim.lsp.log_levels.ERROR)
			return
		end

		if not result or vim.tbl_isempty(result) then
			vim.notify("Nothing renamed", vim.lsp.log_levels.WARN)
			return
		end

		local client = vim.lsp.get_client_by_id(ctx.client_id)
		vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)

		local changed_instances = 0
		local changed_files = 0

		local with_edits = result.documentChanges ~= nil
		for _, change in pairs(result.documentChanges or result.changes) do
			changed_instances = changed_instances + (with_edits and #change.edits or #change)
			changed_files = changed_files + 1
		end

		local message = string.format(
			"Renamed %s instance%s in %s file%s",
			changed_instances,
			changed_instances == 1 and "" or "s",
			changed_files,
			changed_files == 1 and "" or "s"
		)
		vim.notify(message)
	end)
end

--------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>V", perform_lsp_rename)

local aaaa = 10
print("🪚 bbbb: " .. tostring(aaaa))
