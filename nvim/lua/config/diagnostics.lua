local u = require("config.utils")
--------------------------------------------------------------------------------

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

-- BORDERS FOR FLOATS & VIRTUAL TEXT
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

---This function fixes that efm does not separate code & source, but puts them
---together into the diagnostic message
---@param diag diagnostic
---@return diagnostic
---@nodiscard
local function parseEfmDiagnostic(diag)
	-- EXAMPLES: source at the beginning, rule location variable
	-- "[shellcheck] Useless echo? Instead of 'cmd $(echo foo)', just use 'cmd foo'. [SC2116]"
	-- "[selene] [parenthese_conditions]: lua does not require parentheses around conditions"

	local efmSource = diag.message:match("^%[(%a+)%] ")
	-- prevent false positives or multiple efm diagnostic parsings
	if not efmSource then return diag end

	diag.message = diag.message:gsub("^%[%a+%] ", "")
	diag.source = efmSource

	local efmCode = diag.message:match(" ?%[([%w_-]+)%]:? ?")
	diag.message = diag.message:gsub(" ?%[[%w_-]+%]:? ?", "")
	diag.code = efmCode

	return diag
end

---@nodiscard
---@param diag diagnostic
---@return string text to display
local function diagnosticFmt(diag)
	diag = parseEfmDiagnostic(diag)
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
		border = u.borderStyle,
		max_width = 75,
		header = "", -- remove "Diagnostics:" heading
	},
}

--------------------------------------------------------------------------------

---@param diag diagnostic
local function searchForTheRule(diag)
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

local M = {}

---Select from rules on the same line as the cursor, if more than one, uses
---vim.ui.select to choose from them.
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
		}, function(diag)
			if not diag then return end -- aborted input
			searchForTheRule(diag)
		end)
	end
end
return M
