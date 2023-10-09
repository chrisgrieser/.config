-- SIGN ICONS
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

---@param diag Diagnostic
---@return string
local function diagnosticFmt(diag)
	local source = diag.source and " (" .. diag.source:gsub("%.$", "") .. ")" or ""
	return diag.message .. source
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
		border = require("config.utils").borderStyle,
		max_width = 75,
		header = "", -- remove "Diagnostics:" heading
	},
}
