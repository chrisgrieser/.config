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

	-- notification
	local pluralS = changeCount > 1 and "s" or ""
	local msg = ("%s instance%s"):format(changeCount, pluralS)
	if #changedFiles > 1 then
		msg = msg .. (" in %s files:\n"):format(#changedFiles) .. table.concat(changedFiles, "\n")
	end
	vim.notify(msg, nil, { title = "Renamed with LSP" })

	-- SAVE ALL
	if #changedFiles > 1 then vim.cmd.wall() end
end
--------------------------------------------------------------------------------

-- pause inlay hints in insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function(ctx) vim.lsp.inlay_hint.enable(false, { bufnr = ctx.buf }) end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function(ctx) vim.lsp.inlay_hint.enable(true, { bufnr = ctx.buf }) end,
})

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
	local client = vim.lsp.get_clients({ name = ctx.args })[1]
	local newBuf = vim.api.nvim_create_buf(true, true)
	vim.bo[newBuf].filetype = "lua" -- syntax highlighting
	local info = {
		capabilities = client.capabilities,
		server_capabilities = client.server_capabilities,
		config = client.config,
	}
	vim.api.nvim_buf_set_lines(newBuf, 0, -1, false, vim.split(vim.inspect(info), "\n"))
	vim.api.nvim_buf_set_name(newBuf, client.name .. " capabilities")
	vim.cmd.buffer(newBuf) -- open
end, {
	nargs = 1,
	complete = function()
		return vim.iter(vim.lsp.get_clients { bufnr = 0 })
			:map(function(client) return client.name end)
			:totable()
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
		float = true,
	},
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
