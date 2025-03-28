-- HANDLERS

-- `vim.lsp.buf.rename`: add notification & writeall to renaming
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
	local msg = ("[%d] instance%s"):format(changeCount, pluralS)
	if #changedFiles > 1 then
		msg = ("**%s in [%d] files**\n%s"):format(
			msg,
			#changedFiles,
			table.concat(changedFiles, "\n")
		)
	end
	vim.notify(msg, nil, { title = "Renamed with LSP", icon = "󰑕" })

	-- save all
	if #changedFiles > 1 then vim.cmd.wall() end
end

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
-- DIAGNOSTICS

---@param diag vim.Diagnostic
---@return string displayedText
local function addCodeAndSourceAsSuffix(diag)
	if not diag.source then return "" end
	local source = diag.source:gsub(" ?%.$", "") -- remove trailing dot for `lua_ls`
	local code = diag.code and ": " .. diag.code or ""
	return (" (%s%s)"):format(source, code)
end

vim.diagnostic.config {
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "▲",
			[vim.diagnostic.severity.INFO] = "●",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
	virtual_text = {
		severity = { min = vim.diagnostic.severity.WARN }, -- leave out `HINT` & `INFO`
		suffix = addCodeAndSourceAsSuffix,
	},
	float = {
		max_width = 70,
		header = "",
		prefix = function(_, _, total) return (total > 1 and "• " or ""), "Comment" end,
		suffix = function(diag) return addCodeAndSourceAsSuffix(diag), "Comment" end,
	},
}
