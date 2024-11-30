-- Add notification & writeall to renaming
local originalRenameHandler = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
	originalRenameHandler(err, result, ctx, config)
	if err or not result then return end

	-- count changes
	local changes = result.changes or result.documentChanges or {}
	local changedFiles = vim.iter(vim.tbl_keys(changes))
		:filter(function(file) return #changes[file] > 0 end)
		:map(function(file) return "- " .. vim.fs.basename(file) end)
		:totable()
	local changeCount = 0
	for _, change in pairs(changes) do
		changeCount = changeCount + #(change.edits or change)
	end

	-- notification
	local pluralS = changeCount > 1 and "s" or ""
	local newName = ctx.params.newName
	local msg = ("Renamed [%d] instance%s to [%s]"):format(changeCount, pluralS, newName)
	if #changedFiles > 1 then
		msg = ("**Renamed [%d] instance%s in %d files to [%s]**\n%s"):format(
			changeCount,
			pluralS,
			#changedFiles,
			newName,
			table.concat(changedFiles, "\n")
		)
	end
	vim.notify(msg, nil, { title = "LSP", icon = "󰑕" })

	-- SAVE ALL
	if #changedFiles > 1 then vim.cmd.wall() end
end

--------------------------------------------------------------------------------

-- `vim.lsp.buf.signature_help()`
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = vim.g.borderStyle,
})

-- `vim.lsp.buf.hover()`
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = vim.g.borderStyle,
	title = " LSP Hover ",
	max_width = 75,
})

--------------------------------------------------------------------------------

-- pause inlay hints in insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
	desc = "User: Disable LSP inlay hints",
	callback = function(ctx) vim.lsp.inlay_hint.enable(false, { bufnr = ctx.buf }) end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	desc = "User: Enable LSP inlay hints",
	callback = function(ctx) vim.lsp.inlay_hint.enable(true, { bufnr = ctx.buf }) end,
})

--------------------------------------------------------------------------------

vim.api.nvim_create_user_command("LspCapabilities", function(ctx)
	local client = vim.lsp.get_clients({ name = ctx.args })[1]
	local newBuf = vim.api.nvim_create_buf(true, true)
	local info = {
		capabilities = client.capabilities,
		server_capabilities = client.server_capabilities,
		config = client.config,
	}
	vim.api.nvim_buf_set_lines(newBuf, 0, -1, false, vim.split(vim.inspect(info), "\n"))
	vim.api.nvim_buf_set_name(newBuf, client.name .. " capabilities")
	vim.bo[newBuf].filetype = "lua" -- syntax highlighting
	vim.cmd.buffer(newBuf) -- open
	vim.keymap.set("n", "q", vim.cmd.bdelete, { buffer = newBuf })
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
	jump = { float = true }, -- (nvim 0.11)
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
		border = vim.g.borderStyle,
		max_width = 70,
		header = "",
		prefix = function(_, _, total) return (total > 1 and "• " or " "), "Comment" end,
		suffix = function(diag) return addCodeAndSourceAsSuffix(diag), "Comment" end,
	},
}
