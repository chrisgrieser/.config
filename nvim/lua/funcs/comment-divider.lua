local M = {}
local linechar = "─"

function M.commentHr()
	---@diagnostic disable: param-type-mismatch
	local wasOnBlank = vim.api.nvim_get_current_line() == ""
	local indent = vim.fn.indent(".")
	local textwidth = vim.bo.textwidth
	local comStr = vim.bo.commentstring
	local ft = vim.bo.filetype
	local comStrLength = #(comStr:gsub(" ?%%s ?", ""))

	if comStr == "" then
		vim.notify(" No commentstring for this filetype available.", vim.log.levels.WARN)
		return
	end
	if comStr:find("-") then linechar = "-" end

	local linelength = textwidth - indent - comStrLength
	local fullLine = string.rep(linechar, linelength)
	local hr = comStr:gsub(" ?%%s ?", fullLine)
	if ft == "markdown" then hr = "---" end

	local linesToAppend = { "", hr, "" }
	if wasOnBlank then linesToAppend = { hr, "" } end

	vim.fn.append(".", linesToAppend)

	-- shorten if it was on blank line, since fn.indent() does not return indent
	-- line would have if it has content
	if wasOnBlank then
		vim.cmd.normal { "j==", bang = true }
		local hrIndent = vim.fn.indent(".")

		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = vim.api.nvim_get_current_line()
		hrLine = hrLine:gsub(linechar, "", hrIndent)
		vim.fn.setline(".", hrLine)
	else
		vim.cmd.normal { "jj==", bang = true }
	end
	---@diagnostic enable: param-type-mismatch
end

return M
