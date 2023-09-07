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

---@class diagnostic nvim diagnostic https://neovim.io/doc/user/diagnostic.html#diagnostic-structure
---@field message string
---@field source string
---@field code string
---@field bufnr number

---@param diag diagnostic
---@return diagnostic
---@nodiscard
local function parseEfmDiagnostic(diag)
	-- EXAMPLES
	-- [shellcheck] Useless echo? Instead of 'cmd $(echo foo)', just use 'cmd foo'. [SC2116]
	-- [selene] [parenthese_conditions]: lua does not require parentheses around conditions

	local efmSource = diag.message:match("^%[(%a+)%] ")
	diag.message = diag.message:gsub("^%[%a+%] ", "")
	diag.source = efmSource

	if not efmSource then return diag end

	local efmCode = diag.message:match(" ?%[(%a+)%]:? ?")
	diag.message = diag.message:gsub(" ?%[(%a+)%]:? ?", "")
	diag.code = efmCode

	return diag
end

---@nodiscard
---@param diag diagnostic
---@return string text to display
local function diagnosticFmt(diag)
	diag = parseEfmDiagnostic(diag)
	local msg = diag.message

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

--------------------------------------------------------------------------------

---@param diag diagnostic
local function searchForTheRule(diag)
	if not diag then return end
	diag = parseEfmDiagnostic(diag)
	if not (diag.code and diag.source) then
		u.notify("", "diagnostic without code or source", "warn")
		return
	end
	local query = (diag.code .. " " .. diag.source)
	vim.fn.setreg("+", query)
	local url = ("https://duckduckgo.com/?q=%s+%%21ducky&kl=en-us"):format(query:gsub(" ", "+"))
	vim.fn.system { "open", url }
end

if (1 == 2) then print "hi" end

local M = {}
function M.ruleSearch()
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diags = vim.diagnostic.get(0, { lnum = lnum })
	if #diags == 0 then
		u.notify("", "No diagnostics found", "warn")
		return
	elseif #diags == 1 then
		searchForTheRule(diags[1])
	else
		vim.ui.select(diags, {
			prompt = "Select Rule to search:",
			format_item = function(diag) return diag.message end,
		}, function(diag) searchForTheRule(diag) end)
	end
end
return M
