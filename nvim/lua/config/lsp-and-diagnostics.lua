-- Add notification & writeall to renaming
-- PENDING https://github.com/neovim/neovim/pull/26616
local originalRenameHandler = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
	originalRenameHandler(err, result, ctx, config)
	if err or not result then return end

	-- save all
	vim.cmd.wall()

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

--------------------------------------------------------------------------------

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
	local clients = vim.lsp.get_clients(filter)
	local clientInfo = vim.tbl_map(
		function(client) return client.name .. "\n" .. vim.inspect(client) end,
		clients
	)
	local msg = table.concat(clientInfo, "\n\n")
	vim.notify(msg)
end, {
	nargs = "?",
	complete = function()
		local clients = vim.tbl_map(
			function(client) return client.name end,
			vim.lsp.get_clients()
		)
		table.sort(clients)
		vim.fn.uniq(clients)
		return clients
	end,
})

--------------------------------------------------------------------------------
-- DIAGNOSTICS

local function changeSeverity(err, result, ctx, config)
	result.diagnostics = vim.tbl_map(function(diag)
		local consoleLog = diag.source == "biome" and diag.code == "no-console"
		local cssImportant = diag.source == "stylelintplus"
			and diag.code == "declaration-no-important"
		local tsWarnCode = { 6133, 2304 }
		local tsWarn = diag.source == "typescript" and vim.tbl_contains(tsWarnCode, diag.code)

		if consoleLog or cssImportant then
			diag.severity = vim.diagnostic.severity.HINT
		elseif tsWarn then
			diag.severity = vim.diagnostic.severity.WARN
		end
		return diag
	end, result.diagnostics)
	vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
end
vim.lsp.handlers["textDocument/publishDiagnostics"] = changeSeverity

---@param diag vim.Diagnostic
---@return string displayedText
local function addCodeAndSourceAsSuffix(diag)
	if not diag.source then return "" end
	local source = diag.source:gsub(" ?%.$", "") -- rm trailing dot for lua_ls
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
