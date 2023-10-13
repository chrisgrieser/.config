-- SIGN ICONS
local diagnosticTypes = {
	Error = "",
	Warn = "▲",
	Info = "●",
	Hint = "",
}
for type, icon in pairs(diagnosticTypes) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

--------------------------------------------------------------------------------
-- cause lua_ls leaves annoying dot in their source…
---@param diag Diagnostic
---@return string
local function rmTrailDot(diag)
	local msg = diag.message:gsub(" ?%.$", "")
	return msg
end

---@param diag Diagnostic
---@param mode "virtual_text"|"float"
---@return string displayedText
---@return string? highlight_group
local function diagSuffix(diag, mode)
	if not (diag.source or diag.code) then return "" end
	local source = diag.source and diag.source:gsub(" ?%.$", "") or ""

	local docsIcon = ""
	local installed, rulebook = pcall(require, "rulebook")
	if installed and rulebook then docsIcon = rulebook.hasDocs(diag) and "  " or "" end

	if mode == "virtual_text" then
		return (" %s%s"):format(source, docsIcon)
	elseif mode == "float" then
		local rule = diag.code and ": " .. diag.code or ""
		return (" %s%s%s"):format(source, rule, docsIcon), "Comment"
	end
	return "??"
end

vim.diagnostic.config {
	virtual_text = {
		severity = { min = vim.diagnostic.severity.INFO }, -- leave out hints
		spacing = 1,
		format = rmTrailDot,
		suffix = function(diag) return diagSuffix(diag, "virtual_text") end,
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
		format = rmTrailDot,
		suffix = function(diag) return diagSuffix(diag, "float") end,
	},
}
