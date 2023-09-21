local M = {}
local fn = vim.fn
--------------------------------------------------------------------------------

---@class ruleIgnoreConfig
---@field comment string|string[] with %s for the rule id
---@field type "sameLine"|"nextLine"|"enclose"

---@type table<string, ruleIgnoreConfig>
local ignoreRuleData = {
	shellcheck = {
		comment = "# shellcheck disable=%s",
		type = "nextLine",
	},
	selene = {
		comment = "-- selene: allow(%s)",
		type = "nextLine",
	},
	vale = {
		comment = { "<!-- vale %s = NO -->", "<!-- vale %s = YES -->" },
		type = "enclose",
	},
	yamllint = {
		comment = "# yamllint disable-line rule:%s",
		type = "nextLine",
	},
	stylelint = {
		comment = "/* stylelint-disable-next-line %s */",
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
	local escapedQuery = query:gsub(" ", "+") -- valid escaping for DuckDuckGo

	fn.setreg("+", query)

	local url = ("https://duckduckgo.com/?q=%s+%%21ducky&kl=en-us"):format(escapedQuery)

	-- open with the OS-specific shell command
	local opener
	if fn.has("macunix") == 1 then
		opener = "open"
	elseif fn.has("linux") == 1 then
		opener = "xdg-open"
	elseif fn.has("win64") == 1 or fn.has("win32") == 1 then
		opener = "start"
	end
	local openCommand = string.format("%s '%s' >/dev/null 2>&1", opener, url)
	fn.system(openCommand)
end

---@param diag diagnostic
local function addIgnoreComment(diag)
	if not validDiagObj(diag) then return end
	if not ignoreRuleData[diag.source] then
		notify(
			("There is no ignore rule configuration for %s %s."):format(diag.source, diag.code)
				.. "\nPlease make a PR to add support for it.",
			"warn"
		)
		return
	end

	-- insert rule id and indentation into comment
	local currentIndent = vim.api.nvim_get_current_line():match("^%s*")
	local ignoreComment = ignoreRuleData[diag.source].comment
	if type(ignoreComment) == "string" then ignoreComment = { ignoreComment } end
	for i = 1, #ignoreComment, 1 do
		ignoreComment[i] = currentIndent .. ignoreComment[i]:format(diag.code)
	end

	-- add comment
	local ignoreType = ignoreRuleData[diag.source].type
	if ignoreType == "nextLine" then
		local prevLineNum = vim.api.nvim_win_get_cursor(0)[1] - 1
		vim.api.nvim_buf_set_lines(0, prevLineNum, prevLineNum, false, ignoreComment)
	elseif ignoreType == "sameLine" then
		local currentLine = vim.api.nvim_get_current_line():gsub("%s+$", "")
		vim.api.nvim_set_current_line(currentLine .. " " .. ignoreComment[1])
	elseif ignoreType == "enclose" then
		local prevLineNum = vim.api.nvim_win_get_cursor(0)[1]
		local nextLineNum = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_buf_set_lines(0, nextLineNum, nextLineNum, false, {ignoreComment[2]})
		vim.api.nvim_buf_set_lines(0, prevLineNum, prevLineNum, false, {ignoreComment[1]})
	end
end

--------------------------------------------------------------------------------

---Search via DuckDuckGo for the rule
function M.lookupRule() selectRuleInCurrentLine(searchForTheRule) end

---Add ignore comment for the rule
function M.ignoreRule() selectRuleInCurrentLine(addIgnoreComment) end

return M
