local M = {}

local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

--------------------------------------------------------------------------------
-- CONFIG
local commentChar = "─"
local commentWidth = tostring(vim.opt_local.colorcolumn:get()[1]) - 1
local toggleSigns = {
	["|"] = "&",
	[","] = ";",
	["'"] = '"',
	["^"] = "$",
	["/"] = "*",
	["+"] = "-",
	["("] = ")",
	["["] = "]",
	["{"] = "}",
	["<"] = ">",
}
--------------------------------------------------------------------------------

function M.commentHr()
	local wasOnBlank = vim.api.nvim_get_current_line() == ""
	local indent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch
	local comStr = vim.bo.commentstring
	local ft = vim.bo.filetype
	local comStrLength = #(comStr:gsub(" ?%%s ?", ""))

	if comStr == "" then
		vim.notify(" No commentstring for this filetype available.", vim.log.levels.WARN)
		return
	end
	if comStr:find("-") then commentChar = "-" end

	local linelength = commentWidth - indent - comStrLength

	-- the common formatters (black and stylelint) demand extra spaces
	local fullLine
	if ft == "css" then
		fullLine = " " .. commentChar:rep(linelength - 2) .. " "
	elseif ft == "python" then
		fullLine = " " .. commentChar:rep(linelength - 1)
	else
		fullLine = commentChar:rep(linelength)
	end

	-----------------------------------------------------------------------------
	-- set HR
	local hr = comStr:gsub(" ?%%s ?", fullLine)
	if ft == "markdown" then hr = "---" end

	-----------------------------------------------------------------------------

	local linesToAppend = { "", hr, "" }
	if wasOnBlank then linesToAppend = { hr, "" } end

	vim.fn.append(".", linesToAppend) ---@diagnostic disable-line: param-type-mismatch

	-- shorten if it was on blank line, since fn.indent() does not return indent
	-- line would have if it has content
	if wasOnBlank then
		vim.cmd.normal { "j==", bang = true }
		local hrIndent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch

		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = vim.api.nvim_get_current_line()
		hrLine = hrLine:gsub(commentChar, "", hrIndent)
		vim.api.nvim_set_current_line(hrLine)
	else
		vim.cmd.normal { "jj==", bang = true }
	end
end

function M.toggleCase()
	local col = vim.fn.col(".") -- fn.col correctly considers tab-indentation
	local charUnderCursor = vim.api.nvim_get_current_line():sub(col, col)
	local isLetter = charUnderCursor:find("^%a$")
	if isLetter then
		normal("~h")
		return
	end
	for left, right in pairs(toggleSigns) do
		if charUnderCursor == left then normal("r" .. right) end
		if charUnderCursor == right then normal("r" .. left) end
	end
end

function M.openNewScope()
	local line = vim.api.nvim_get_current_line()
	local trailComma = line:match(",?$")
	line = line:gsub("[, ]+$", "") .. " {" -- edit current line
	vim.api.nvim_set_current_line(line)
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	local indent = line:match("^%s*")
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. "\t", indent .. "}" .. trailComma })
	vim.api.nvim_win_set_cursor(0, { ln + 1, 1 }) -- go line down
	vim.cmd.startinsert { bang = true }
end

function M.ruleSearch()
	local lnum = vim.fn.line(".") - 1
	local diags = vim.diagnostic.get(0, { lnum = lnum })
	if vim.tbl_isempty(diags) then
		vim.notify("No diagnostics found", vim.log.levels.WARN)
		return
	end
	for _, diag in ipairs(diags) do
		---@diagnostic disable-next-line: undefined-field
		if diag.code and diag.source then
			---@diagnostic disable-next-line: undefined-field
			local query = (diag.code .. " " .. diag.source)
			vim.fn.setreg("+", query)
			local url = ("https://duckduckgo.com/?q=%s+%%21ducky&kl=en-us"):format(query:gsub(" ", "+"))
			vim.fn.system { "open", url }
		end
	end
end

function M.scrollHoverWin(direction)
	local a = vim.api
	local scrollCmd = (direction == "down" and "5j" or "5k")
	local winIds = a.nvim_tabpage_list_wins(0)
	for _, winId in ipairs(winIds) do
		local isHover = a.nvim_win_get_config(winId).relative ~= ""
			and a.nvim_win_get_config(winId).focusable
		if isHover then
			a.nvim_set_current_win(winId)
			normal(scrollCmd)
			return
		end
	end
	vim.notify("No floating windows found. ", vim.log.levels.WARN)
end

---@param direction "up"|"down"
function M.gotoNextIndentChange(direction)
	local isBlankLine = function(lnum) return vim.fn.getline(lnum):find("^%s*$") end

	local lastLineNum = vim.api.nvim_buf_line_count(0)
	local increment = direction == "up" and -1 or 1
	local stopAtLine = direction == "up" and 1 or lastLineNum
	local lineNum, colNum = unpack(vim.api.nvim_win_get_cursor(0))

	-- blank lines always have indent 0, so we go to the next non-blank to
	-- determine the "true" indent
	local currentIndent
	while true do
		currentIndent = vim.fn.indent(lineNum)
		if not isBlankLine(lineNum) then break end
		lineNum = lineNum + increment
	end

	local targetLineNum
	for i = lineNum, stopAtLine, increment do
		targetLineNum = i
		local indent = vim.fn.indent(i)
		if indent ~= currentIndent and not isBlankLine(i) then break end
	end
	vim.api.nvim_win_set_cursor(0, { targetLineNum, colNum })
end

--------------------------------------------------------------------------------

---Runs make, same as `:make` but does not fill the quickfix list. Useful make
--is only used as task runner
function M.make()
	local output = vim.fn.system { "make", "--silent" }
	local logLevel = vim.v.shell_error == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
	vim.notify(output, logLevel)
end

function M.selectMake()
	local makefile = vim.loop.cwd() .. "/Makefile"
	local fileExists = vim.loop.fs_stat(makefile) ~= nil
	if not fileExists then
		vim.notify("Makefile not found.", vim.log.levels.WARN)
		return
	end

	-- color comment
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "DressingSelect",
		once = true, -- to not affect other dressing selections
		callback = function()
			vim.fn.matchadd("MakeComment", "#.*$")
			vim.api.nvim_set_hl(0, "MakeComment", { link = "Comment" })
		end,
	})

	local recipes = {}
	for line in io.lines(makefile) do
		local commentIndentOrBlank = line:find("^[%s#.]") or line:find("^%s*$")
		if not commentIndentOrBlank then table.insert(recipes, line) end
	end

	vim.ui.select(recipes, { prompt = " Select recipe:" }, function(recipe)
		if recipe == nil then return end
		local output = vim.fn.system { "make", "--silent", recipe }
		local logLevel = vim.v.shell_error == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
		vim.notify(output, logLevel)
	end)
end

--------------------------------------------------------------------------------

return M
