local u = require("config.utils")
--------------------------------------------------------------------------------

-- Sign Icons
local diagnosticTypes = { Error = "", Warn = "▲", Info = "", Hint = "" }
for type, icon in pairs(diagnosticTypes) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

--------------------------------------------------------------------------------

-- Borders for Floats & Virtual Text
require("lspconfig.ui.windows").default_options.border = u.borderStyle

-- INFO this needs to be disabled for noice.nvim
-- vim.lsp.handlers["textDocument/signatureHelp"] =
-- 	vim.lsp.with(vim.lsp.handlers.signature_help, { border = u.borderStyle })
-- vim.lsp.handlers["textDocument/hover"] =
-- vim.lsp.with(vim.lsp.handlers.hover, { border = u.borderStyle })

--------------------------------------------------------------------------------

-- https://neovim.io/doc/user/diagnostic.html#diagnostic-structure
local function diagnosticFmt(diag, type)
	local msg = diag.message

	if diag.source == "Ruff" and type == "virtual_text" then return diag.code .. ": " .. msg end

	if msg:find("^%[stylelint%]") or msg:find("^%[markdownlint%]") then
		diag.severity = vim.diagnostic.severity.WARN
	end

	local efmSource = msg:match("^%[(%a+)%] ")
	if efmSource then
		msg = msg:gsub("^%[%a+%] ", "")
		diag.source = efmSource
	end

	local source = diag.source and " (" .. diag.source:gsub("%.$", "") .. ")" or ""

	return msg .. source
end

vim.diagnostic.config {
	virtual_text = {
		severity = { min = vim.diagnostic.severity.WARN }, -- no text for hints
		source = false, -- already handled by format function
		format = function(diag) return diagnosticFmt(diag, "virtual_text") end,
		spacing = 1,
	},
	float = {
		format = function(diag) return diagnosticFmt(diag, "float") end,
		focusable = true,
		border = u.borderStyle,
		max_width = 75,
		header = "", -- remove "Diagnostics:" heading
	},
}
