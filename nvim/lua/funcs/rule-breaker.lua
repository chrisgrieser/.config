local M = {}
--------------------------------------------------------------------------------

---@class ruleIgnoreConfig
---@field ignore string|string[] with %s for the rule id
---@field type "sameLine"|"nextLine"|"enclose"

---@type table<string, ruleIgnoreConfig>
local ignoreRuleData = {
	shellcheck = {
		ignore = "# shellcheck disable=%s",
		type = "nextLine",
	},
	selene = {
		ignore = "-- selene: allow(%s)",
		type = "nextLine",
	},
	vale = {
		ignore = { "<!-- vale %s = NO -->", "<!-- vale %s = YES -->" },
		type = "enclose",
	},
	yamllint = {
		ignore = "# yamllint disable-line rule:%s",
		type = "nextLine",
	},
	stylelint = {
		ignore = "/* stylelint-disable-next-line %s */",
		type = "nextLine",
	},
}

--------------------------------------------------------------------------------

---@class diagnostic nvim diagnostic https://neovim.io/doc/user/diagnostic.html#diagnostic-structure
---@field message string
---@field source string -- linter of LSP name
---@field code string -- rule id
---@field bufnr number

---Send notification
---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	local pluginName = "nvim-rule-breaker"
	vim.notify(msg, vim.log.levels[level:upper()], { title = pluginName })
end

---Selects a rule in the current line. If one rule, automatically selects it
---@param operation function(diag)
local function selectRuleInCurrentLine(operation)
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local curLineDiags = vim.diagnostic.get(0, { lnum = lnum })
	if #curLineDiags == 0 then
		notify("No diagnostics found", "warn")
	elseif #curLineDiags == 1 then
		operation(curLineDiags[1])
	else
		vim.ui.select(curLineDiags, {
			prompt = "Select Rule:",
			format_item = function(diag) return diag.message end,
		}, function(diag)
			if not diag then return end -- aborted input
			operation(diag)
		end)
	end
end

---@param diag diagnostic
---@return boolean whether rule is valid
local function validDiagObj(diag)
	if not diag.code then
		notify("Diagnostic is missing a code (rule id)", "warn")
		return false
	elseif not diag.source then
		notify("Diagnostic is missing a source", "warn")
		return false
	end
	return true
end

--------------------------------------------------------------------------------

---@param diag diagnostic
local function searchForTheRule(diag)
	if not validDiagObj(diag) then return end
	local query = (diag.code .. " " .. diag.source)

	vim.fn.setreg("+", query)

	local url = ("https://duckduckgo.com/?q=%s+%%21ducky&kl=en-us"):format(query:gsub(" ", "+"))
	vim.fn.system { "open", url }
end

---@param diag diagnostic
local function addIgnoreComment(diag)
	if not validDiagObj(diag) then return end
	if not ignoreRuleData[diag.source] then
		notify(
			("There is no ignore rule configuration for %s %s."):format(diag.source, diag.code)
				.. "\nPlease make a PR to the nvim-rule-break repo.",
			"warn"
		)
		return
	end
end

--------------------------------------------------------------------------------

---Search via DuckDuckGo for the rule
function M.lookupRule() selectRuleInCurrentLine(searchForTheRule) end

---Add ignore comment for the rule
function M.ignoreRule() selectRuleInCurrentLine(addIgnoreComment) end

return M
