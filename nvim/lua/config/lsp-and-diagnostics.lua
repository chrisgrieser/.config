-- Add notification & writeall to renaming
local originalRenameHandler = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
	originalRenameHandler(err, result, ctx, config)
	if err or not result then return end

	-- count changes
	local changes = result.changes or result.documentChanges or {}
	local changedFiles = vim.iter(vim.tbl_keys(changes))
		:filter(function(file) return #changes[file] > 0 end)
		:map(function(file) return "• " .. vim.fs.basename(file) end)
		:totable()
	local changeCount = 0
	for _, change in pairs(changes) do
		changeCount = changeCount + #(change.edits or change)
	end

	-- save all, if more than one file changed
	if #changedFiles > 1 then vim.cmd.wall() end

	-- notification
	local pluralS = changeCount > 1 and "s" or ""
	local msg = ("%s instance%s"):format(changeCount, pluralS)
	if #changedFiles > 1 then
		msg = msg .. (" in %s files:\n"):format(#changedFiles) .. table.concat(changedFiles, "\n")
	end
	vim.notify(msg, nil, { title = "Renamed with LSP" })
end
--------------------------------------------------------------------------------

-- pause inlay hints in insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function(ctx) vim.lsp.inlay_hint.enable(false, { bufnr = ctx.buf }) end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function(ctx) vim.lsp.inlay_hint.enable(true, { bufnr = ctx.buf }) end,
})

-- logging
vim.lsp.log.set_format_func(vim.inspect)
vim.lsp.log.set_level(vim.lsp.log.levels.WARN)

-- appearance
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = vim.g.borderStyle,
})

-- INFO this needs to be disabled for noice.nvim
-- vim.lsp.handlers["textDocument/hover"] =
-- vim.lsp.with(vim.lsp.handlers.hover, { border = vim.g.myBorderStyle })

--------------------------------------------------------------------------------

-- :LspCapabilities
-- no arg: all LSPs attached to current buffer
-- one arg: name of the LSP
vim.api.nvim_create_user_command("LspCapabilities", function(ctx)
	local filter = ctx.args == "" and { bufnr = 0 } or { name = ctx.args }
	local clientInfo = vim.iter(vim.lsp.get_clients(filter))
		:map(function(client) return client.name:upper() .. "\n" .. vim.inspect(client) end)
		:join("\n\n")
	vim.api.nvim_create_autocmd("FileType", {
		once = true,
		pattern = "noice",
		command = "set filetype=lua", -- syntax highlighting
	})
	vim.notify(clientInfo)
end, {
	nargs = "?",
	complete = function()
		local clients = vim.tbl_map(function(client) return client.name end, vim.lsp.get_clients())
		table.sort(clients)
		vim.fn.uniq(clients)
		return clients
	end,
})

--------------------------------------------------------------------------------
-- DIAGNOSTICS

---@param diag vim.Diagnostic
---@return string displayedText
local function addCodeAndSourceAsSuffix(diag)
	if not diag.source then return "" end
	local source = diag.source:gsub(" ?%.$", "") -- rm trailing dot for lua_ls
	local code = diag.code and ": " .. diag.code or ""
	return (" (%s%s)"):format(source, code)
end

vim.diagnostic.config {
	jump = {
		float = 
	}
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "▲",
			[vim.diagnostic.severity.INFO] = "●",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
	virtual_text = {
		severity = { min = vim.diagnostic.severity.WARN }, -- leave out hints & info
		suffix = addCodeAndSourceAsSuffix,
	},
	float = {
		severity_sort = true,
		border = vim.g.borderStyle,
		max_width = 70,
		header = "",
		prefix = { "• ", "Comment" },
		suffix = function(diag) return addCodeAndSourceAsSuffix(diag), "Comment" end,
	},
}
