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

-- `vim.lsp.buf.signature_help`
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = vim.g.borderStyle,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = vim.g.borderStyle,
	title = " LSP hover ",
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

-- lightweight replacement for `fidget.nvim`
-- (uses vim.notify opts tailored to `snacks.nvim`, but should in general work
-- for other notifiers as well)
vim.api.nvim_create_autocmd("LspProgress", {
	desc = "User: LSP progress",
	callback = function(ctx)
		local progress = ctx.data.params.value
		if not progress then return end

		-- GUARD constant notification for `ltex`
		if vim.fn.mode() == "i" and vim.bo.ft == "markdown" then return end

		local clientName = vim.lsp.get_client_by_id(ctx.data.client_id).name
		local text = (progress.title or progress.message or ""):gsub("%.%.%.", "…")
		local msg = vim.trim(("[%s] %s"):format(clientName, text))

		local icon
		if progress.kind == "end" then
			icon = ""
		elseif progress.percentage then
			local progIcons = { "󰋙", "󰫃", "󰫄", "󰫅", "󰫆", "󰫇", "󰫈" }
			local idx = progress.percentage and math.ceil(progress.percentage / 100 * #progIcons) or 1
			if progress.percentage == 0 then idx = 1 end
			icon = progIcons[idx]
		else
			icon = "󰔟"
		end

		vim.notify(msg, vim.log.levels.TRACE, {
			id = "LspProgress",
			icon = icon .. " ",
			style = "minimal",
			timeout = 2500,
			history = false,
		})
	end,
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
		severity = { min = vim.diagnostic.severity.WARN }, -- leave out `HINT` & `INFO`
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
