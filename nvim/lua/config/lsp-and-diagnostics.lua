--------------------------------------------------------------------------------
-- RENAMING add notification & writeall to renaming

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
		local fileList = table.concat(changedFiles, "\n")
		msg = ("**%s in [%d] files**\n%s"):format(msg, #changedFiles, fileList)
	end
	vim.notify(msg, nil, { title = "Renamed with LSP", icon = "󰑕" })

	-- save all
	if #changedFiles > 1 then vim.cmd.wall() end
end

--------------------------------------------------------------------------------
-- INLAY HINTS pause in insert mode
do
	vim.api.nvim_create_autocmd("InsertEnter", {
		desc = "User: Disable LSP inlay hints",
		callback = function(ctx) vim.lsp.inlay_hint.enable(false, { bufnr = ctx.buf }) end,
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		desc = "User: Enable LSP inlay hints",
		callback = function(ctx) vim.lsp.inlay_hint.enable(true, { bufnr = ctx.buf }) end,
	})
end

--------------------------------------------------------------------------------
-- DIAGNOSTICS display

---@param diag vim.Diagnostic
---@return string displayedText
local function formatDiagnostic(diag)
	if not diag.source then return diag.message end

	local source = diag.source:gsub(" ?%.$", "") -- remove trailing dot for `lua_ls`
	local msg = diag.message:gsub("%.%s*$", "")

	if not diag.code then return ("%s (%s)"):format(msg, source, diag.code) end
	return ("%s [%s: %s]"):format(msg, source, diag.code)
end

vim.diagnostic.config {
	signs = {
		text = { "", "▲", "●", "" }, -- Error, Warn, Info, Hint
	},
	virtual_text = {
		severity = { min = vim.diagnostic.severity.WARN }, -- leave out `HINT` & `INFO`
		format = formatDiagnostic,
	},
	virtual_lines = false,
}

--------------------------------------------------------------------------------
-- DIAGNOSTICS as virtual lines when jumping

local function diagnosticsAsVirtualLines()
	local initialVirtTextConf = vim.diagnostic.config().virtual_text
	vim.diagnostic.config {
		virtual_text = false,
		virtual_lines = { current_line = true, format = formatDiagnostic },
	}
	vim.defer_fn(function() -- deferred to not trigger by jump itself
		vim.api.nvim_create_autocmd("CursorMoved", {
			desc = "User(once): Reset diagnostics virtual lines",
			once = true,
			callback = function()
				vim.diagnostic.config {
					virtual_lines = false,
					virtual_text = initialVirtTextConf,
				}
			end,
		})
	end, 1)
end

local keymap = require("config.utils").uniqueKeymap

keymap("n", "ge", function()
	vim.diagnostic.jump { count = 1 }
	diagnosticsAsVirtualLines()
end, { desc = "󰒕 Next diagnostic" })

keymap("n", "gE", function()
	vim.diagnostic.jump { count = -1 }
	diagnosticsAsVirtualLines()
end, { desc = "󰒕 Prev diagnostic" })
