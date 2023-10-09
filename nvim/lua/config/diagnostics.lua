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

vim.diagnostic.config {
	virtual_text = {
		severity = { min = vim.diagnostic.severity.INFO },
		source = false,
		spacing = 1,
		suffix = function (diag)
			local source = diag.source:gsub("%.$", "")
			return (" (%s)"):format(source)
		end,
	},
	float = {
		focusable = true,
		severity_sort = true,
		border = require("config.utils").borderStyle,
		max_width = 75,
		header = false,
		prefix = function(_, _, total)
			if total == 1 then return "" end
			return "• ", "NonText"
		end,
		suffix = function(diag) ---@param diag Diagnostic
			local source = diag.source:gsub("%.$", "")
			local rule = diag.code and diag.code .. " " or ""
			return ("(%s%s)"):format(source, rule), "NonText"
		end,
	},
}
