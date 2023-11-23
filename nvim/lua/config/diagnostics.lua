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

---@param diag Diagnostic
---@return string
local function diagMsgFormat(diag)
	local msg = diag
		.message
		:gsub(" ?%.$", "") -- trailing dot for lua_ls
		:gsub("`(%w+)` should be `(%w+)`", "%1 󰁔 %2") -- typos
	return msg
end

---@param diag Diagnostic
---@param mode "virtual_text"|"float"
---@return string displayedText
---@return string? highlight_group
local function diagSourceAsSuffix(diag, mode)
	if not (diag.source or diag.code) then return "" end
	local source = (diag.source or "")
		:gsub(" ?%.$", "") -- trailing dot for lua_ls
		:gsub("%[typos%] typo", "typos") -- fix `typos` source
	local rule = diag.code and ": " .. diag.code or ""

	if mode == "virtual_text" then
		return (" (%s%s)"):format(source, rule)
	elseif mode == "float" then
		return (" %s%s"):format(source, rule), "Comment"
	end
	return ""
end

---@param diag Diagnostic
---@return string
local function formatVirtualText(diag)
	if diag.source == "editorconfig-checker" then
		local msg = diag.message:gsub(".*%((.*)%)", "%1")
		return msg
	end
	return diagMsgFormat(diag)
end

vim.diagnostic.config {
	virtual_text = {
		severity = { min = vim.diagnostic.severity.INFO }, -- leave out hints
		spacing = 1,
		format = formatVirtualText,
		suffix = function(diag)
			if diag.source == "editorconfig-checker" then return "" end
			return diagSourceAsSuffix(diag, "virtual_text")
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
		format = diagMsgFormat,
		suffix = function(diag) return diagSourceAsSuffix(diag, "float") end,
	},
}
