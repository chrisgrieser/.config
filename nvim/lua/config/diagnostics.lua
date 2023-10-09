-- SIGN ICONS
local diagnosticTypes = {
	Error = "ﮋ",
	Warn = "▲",
	Info = "♦",
	Hint = "",
}
for type, icon in pairs(diagnosticTypes) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

--------------------------------------------------------------------------------
---@param str string
---@return string
local function rmTrailDot(str)
	str = str:gsub(" ?%.$", "")
	return str
end

vim.diagnostic.config {
	virtual_text = {
		severity = { min = vim.diagnostic.severity.INFO }, -- leave out hints
		source = false, -- added as suffix already
		spacing = 1,
		format = function(diag) return rmTrailDot(diag.message) end,
		suffix = function(diag) ---@param diag Diagnostic
			if not (diag.source) then return "" end
			local source = rmTrailDot(diag.source)
			return (" (%s)"):format(source)
		end,
	},
	float = {
		severity_sort = true,
		border = require("config.utils").borderStyle,
		max_width = 70,
		header = false,
		prefix = function(_, _, total)
			if total == 1 then return "" end
			return "• ", "NonText"
		end,
		format = function(diag) return rmTrailDot(diag.message) end,
		suffix = function(diag) ---@param diag Diagnostic
			if not (diag.source or diag.code) then return "" end
			local source = diag.source and rmTrailDot(diag.source) or ""
			local rule = diag.code and ": " .. diag.code or ""
			return (" (%s%s)"):format(source, rule), "Comment"
		end,
	},
}
