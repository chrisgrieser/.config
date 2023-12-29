local u = require("config.utils")
--------------------------------------------------------------------------------

-- LSP SETTINGS

-- Add notification & writeall to renaming
-- PENDING https://github.com/neovim/neovim/pull/26616
local originalRenameHandler = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config) ---@diagnostic disable-line: duplicate-set-field
	originalRenameHandler(err, result, ctx, config)
	if err or not result then return end

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
	local msg = changeCount .. " instance" .. pluralS
	if #changedFiles > 1 then
		msg = msg .. (" in %s files:\n"):format(#changedFiles) .. table.concat(changedFiles, "\n")
	end
	u.notify("Renamed with LSP", msg)
end

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = u.borderStyle,
})
-- INFO this needs to be disabled for noice.nvim
-- vim.lsp.handlers["textDocument/hover"] =
-- vim.lsp.with(vim.lsp.handlers.hover, { border = u.borderStyle })

--------------------------------------------------------------------------------

-- :LspCapabilities
-- no arg: all LSPs attached to current buffer
-- one arg: name of the LSP
vim.api.nvim_create_user_command("LspCapabilities", function(ctx)
	local filter = ctx.args == "" and { bufnr = vim.api.nvim_get_current_buf() }
		or { name = ctx.args }
	local clients = vim.lsp.get_active_clients(filter)
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
			vim.lsp.get_active_clients()
		)
		table.sort(clients)
		return clients
	end,
})

--------------------------------------------------------------------------------
-- DIAGNOSTICS

local diagnosticTypes = { Error = "", Warn = "▲", Info = "●", Hint = "" }
for type, icon in pairs(diagnosticTypes) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

---@param diag Diagnostic
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

---@param diag Diagnostic
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
		border = u.borderStyle,
		max_width = 70,
		header = false,
		prefix = function(_, _, total)
			if total == 1 then return "" end
			return "• ", "NonText"
		end,
		format = diagMsgFormat,
		suffix = function(diag) return diagSourceAsSuffix(diag, "float") end,
	},
}
