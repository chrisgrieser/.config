-- LSP SETTINGS

-- Add notification & writeall to renaming
-- PENDING https://github.com/neovim/neovim/pull/26616
local originalRenameHandler = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
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
	vim.notify(msg, vim.log.levels.INFO, {
		on_open = function(win)
			local bufnr = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_set_option_value("filetype", "markdown", { buf = bufnr })
		end,
		title = "Renamed with LSP",
	})
end

-- -----------------------------------------------------------------------------
-- other lsp settings

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = vim.g.borderStyle,
})

--------------------------------------------------------------------------------

-- INFO this needs to be disabled for noice.nvim
-- vim.lsp.handlers["textDocument/hover"] =
-- vim.lsp.with(vim.lsp.handlers.hover, { border = vim.g.myBorderStyle })

--------------------------------------------------------------------------------
-- DIAGNOSTICS

local function changeSeverityToInfo(err, result, ctx, config)
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
vim.lsp.handlers["textDocument/publishDiagnostics"] = changeSeverityToInfo

---@param diag vim.Diagnostic
---@return string displayedText
local function addCodeAndSourceAsSuffix(diag)
	local source = (diag.source or ""):gsub(" ?%.$", "") -- rm trailing dot for lua_ls
	local rule = diag.code and ": " .. diag.code or ""
	return (" (%s%s)"):format(source, rule)
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
		severity = { min = vim.diagnostic.severity.INFO }, -- leave out hints
		spacing = 1,
		suffix = addCodeAndSourceAsSuffix,
	},
	float = {
		severity_sort = true,
		border = vim.g.borderStyle,
		max_width = 70,
		header = "",
		prefix = function(_, _, total)
			local bullet = total > 1 and "• " or ""
			return bullet, "Comment"
		end,
		suffix = function(diag) return addCodeAndSourceAsSuffix(diag), "Comment" end,
	},
}
