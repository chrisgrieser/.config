local M = {}

---@param cmd string
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

--------------------------------------------------------------------------------

-- appends a horizontal line, with the language's comment syntax,
-- correctly indented and padded
function M.commentHr()
	local comStr = vim.bo.commentstring
	if comStr == "" then
		vim.notify("No commentstring for this filetype available.", vim.log.levels.WARN)
		return
	end

	local wasOnBlank = vim.api.nvim_get_current_line() == ""
	local startRow = vim.api.nvim_win_get_cursor(0)[1]

	local row = startRow
	local line, indent
	repeat
		line = vim.api.nvim_get_current_line()
		indent = line:match("^%s*")
		row = row - 1
	until vim.fn.getline(row) ~= "" or row == 1

	local comStrLength = #(comStr:gsub(" ?%%s ?", ""))
	local indentLength = vim.bo.expandtab and #indent or #indent * vim.bo.tabstop
	local textwidth = vim.o.textwidth > 0 and vim.o.textwidth or 80
	local hrLength = textwidth - (indentLength + comStrLength)

	-- the common formatters (black and stylelint) demand extra spaces
	local hrChar = comStr:find("%-") and "-" or "─"
	local hr
	if vim.bo.ft == "css" then
		hr = " " .. hrChar:rep(hrLength - 2) .. " "
	elseif vim.bo.ft == "python" then
		hr = " " .. hrChar:rep(hrLength - 1)
	else
		hr = hrChar:rep(hrLength)
	end
	local fullLine = comStr:gsub(" ?%%s ?", hr)
	if vim.bo.ft == "markdown" then fullLine = "---" end

	-- append Lines
	local linesToAppend = wasOnBlank and { fullLine, "" } or { "", fullLine, "" }
	vim.fn.append(".", linesToAppend) ---@diagnostic disable-line: param-type-mismatch

	-- shorten if it was on blank line, since fn.indent() does not return indent
	-- line would have if it has content
	if wasOnBlank then
		normal("j==")
		local hrIndent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch

		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = vim.api.nvim_get_current_line()
		hrLine = hrLine:gsub(hrChar, "", hrIndent)
		vim.api.nvim_set_current_line(hrLine)
	else
		normal("jj==")
	end
end

function M.duplicateLineAsComment()
	local ln, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()
	local indent, content = curLine:match("^(%s*)(.*)")
	local commentedLine = indent .. vim.bo.commentstring:format(content)
	vim.api.nvim_buf_set_lines(0, ln - 1, ln, false, { commentedLine, curLine })
	vim.api.nvim_win_set_cursor(0, { ln + 1, col })
end

function M.appendAtEoL()
	if vim.bo.commentstring == "" then return end

	local line = vim.api.nvim_get_current_line():gsub("%s+$", "")
	local isBlankLine = line == ""
	local comStr = vim.bo.commentstring:format("")
	local pad = isBlankLine and "" or " "

	vim.api.nvim_set_current_line(line .. pad .. comStr)
	vim.cmd.startinsert { bang = true }
end

-- https://jupytext.readthedocs.io/en/latest/formats-scripts.html#the-percent-format
function M.insertDoublePercentComment()
	if vim.bo.commentstring == "" then return end
	local doublePercentCom = vim.bo.commentstring:format("%%")
	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. doublePercentCom })
end

--------------------------------------------------------------------------------
return M
