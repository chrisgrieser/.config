-- LSP SETTINGS

-- Add notification & writeall to renaming
-- PENDING https://github.com/neovim/neovim/pull/26616
local originalRenameHandler = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config) ---@diagnostic disable-line: duplicate-set-field
	originalRenameHandler(err, result, ctx, config)
	if err or not result then return end

	-- save all
	vim.cmd.wall()

	local changes = result.changes or result.documentChanges or {}
	local changedFiles = vim.tbl_keys(changes)
	changedFiles = vim.tbl_filter(function(file) return #changes[file] > 0 end, changedFiles)
	changedFiles = vim.tbl_map(function(file) return "- " .. vim.fs.basename(file) end, changedFiles)

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
	vim.notify(msg, vim.log.levels.INFO, { title = "Renamed with LSP" })
end

-- -----------------------------------------------------------------------------
-- other lsp settings
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = vim.g.borderStyle,
})

-- globally enable by default
vim.lsp.inlay_hint.enable(true)

--------------------------------------------------------------------------------

-- INFO this needs to be disabled for noice.nvim
-- vim.lsp.handlers["textDocument/hover"] =
-- vim.lsp.with(vim.lsp.handlers.hover, { border = vim.g.myBorderStyle })

--------------------------------------------------------------------------------
-- DIAGNOSTICS

-- change severity level
-- PENDING https://github.com/biomejs/biome/discussions/2242
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config) ---@diagnostic disable-line: duplicate-set-field
	result.diagnostics = vim.tbl_map(function(diag)
		if
			(diag.source == "biome" and diag.code == "lint/suspicious/noConsoleLog")
			or (diag.source == "stylelintplus" and diag.code == "declaration-no-important")
		then
			diag.severity = vim.diagnostic.severity.HINT
		end
		return diag
	end, result.diagnostics)
	vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
end

-- Signs
local diagnosticTypes = { Error = "", Warn = "▲", Info = "●", Hint = "" }
for type, icon in pairs(diagnosticTypes) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

---@param diag vim.Diagnostic
---@return string
local function diagMsgFormat(diag)
	local msg = diag.message
	if diag.source == "typos" then
		msg = msg:gsub("should be", "󰁔"):gsub("`", "")
	elseif diag.source == "Lua Diagnostics." then
		msg = msg:gsub("%.$", "")
	end
	return msg
end

---@param diag vim.Diagnostic
---@param mode "virtual_text"|"float"
---@return string displayedText
---@return string? highlight_group
local function diagSourceAsSuffix(diag, mode)
	if not (diag.source or diag.code) then return "" end
	local source = (diag.source or ""):gsub(" ?%.$", "") -- trailing dot for lua_ls
	local rule = diag.code and ": " .. diag.code or ""

	if mode == "virtual_text" then
		return (" (%s%s)"):format(source, rule)
	elseif mode == "float" then
		return (" %s%s"):format(source, rule), "Comment"
	end
	return ""
end

vim.diagnostic.config {
	virtual_text = {
		severity = { min = vim.diagnostic.severity.INFO }, -- leave out hints
		spacing = 1,
		format = diagMsgFormat,
		suffix = function(diag) return diagSourceAsSuffix(diag, "virtual_text") end,
	},
	float = {
		severity_sort = true,
		border = vim.g.borderStyle,
		max_width = 70,
		header = false,
		prefix = function(_, _, total)
			if total == 1 then return "", "" end
			return "• ", "NonText"
		end,
		format = diagMsgFormat,
		suffix = function(diag) return diagSourceAsSuffix(diag, "float") end,
	},
}
