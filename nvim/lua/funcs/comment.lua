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
	local indent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch
	local comStrLength = #(comStr:gsub(" ?%%s ?", ""))
	local commentHrChar = comStr:find("%-") and "-" or "─"
	local textwidth = vim.o.textwidth > 0 and vim.o.textwidth or 80
	local hrLength = textwidth - indent - comStrLength

	-- the common formatters (black and stylelint) demand extra spaces
	local fullLine
	if vim.bo.ft == "css" then
		fullLine = " " .. commentHrChar:rep(hrLength - 2) .. " "
	elseif vim.bo.ft == "python" then
		fullLine = " " .. commentHrChar:rep(hrLength - 1)
	else
		fullLine = commentHrChar:rep(hrLength)
	end

	-- set HR
	local hr = vim.bo.ft == "markdown" and "---" or comStr:gsub(" ?%%s ?", fullLine)
	local linesToAppend = wasOnBlank and { hr, "" } or { "", hr, "" }

	vim.fn.append(".", linesToAppend) ---@diagnostic disable-line: param-type-mismatch

	-- shorten if it was on blank line, since fn.indent() does not return indent
	-- line would have if it has content
	if wasOnBlank then
		normal("j==")
		local hrIndent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch

		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = vim.api.nvim_get_current_line()
		hrLine = hrLine:gsub(commentHrChar, "", hrIndent)
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
	local comStr = " " .. vim.bo.commentstring:format("")
	vim.api.nvim_set_current_line(line .. comStr)
	vim.cmd.startinsert{ bang = true }
end

--------------------------------------------------------------------------------
return M
