local M = {}

--------------------------------------------------------------------------------
-- CONFIG
local linechar = "─"
local width = tostring(vim.opt_local.colorcolumn:get()[1]) - 1

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
	if comStr:find("-") then linechar = "-" end

	local linelength = width - indent - comStrLength
	local fullLine = linechar:rep(linelength)

	-- due to https://stylelint.io/user-guide/rules/comment-whitespace-inside/
	if ft == "css" then fullLine = " " .. linechar:rep(linelength - 2) .. " " end

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
		hrLine = hrLine:gsub(linechar, "", hrIndent)
		vim.api.nvim_set_current_line(hrLine)
	else
		vim.cmd.normal { "jj==", bang = true }
	end
end

--------------------------------------------------------------------------------

return M
