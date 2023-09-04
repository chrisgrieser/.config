local u = require("config.utils")
--------------------------------------------------------------------------------

-- Sign Icons
local diagnosticTypes = {
	Error = "",
	Warn = "▲",
	Info = "",
	Hint = "",
}
for type, icon in pairs(diagnosticTypes) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

--------------------------------------------------------------------------------

-- Borders for Floats & Virtual Text

-- INFO this needs to be disabled for noice.nvim
-- vim.lsp.handlers["textDocument/signatureHelp"] =
-- 	vim.lsp.with(vim.lsp.handlers.signature_help, { border = u.borderStyle })
-- vim.lsp.handlers["textDocument/hover"] =
-- vim.lsp.with(vim.lsp.handlers.hover, { border = u.borderStyle })

--------------------------------------------------------------------------------

-- https://neovim.io/doc/user/diagnostic.html#diagnostic-structure
local function diagnosticFmt(diag)
	local msg = diag.message

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
		format = diagnosticFmt,
		severity = { min = vim.diagnostic.severity.INFO },
		source = false, -- handled by my format function
		spacing = 1,
	},
	float = {
		format = diagnosticFmt,
		focusable = true,
		border = u.borderStyle,
		max_width = 75,
		header = "", -- remove "Diagnostics:" heading
	},
}
