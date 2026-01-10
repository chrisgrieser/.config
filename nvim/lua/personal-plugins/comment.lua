local M = {}
--------------------------------------------------------------------------------

local config = {
	formatterWantsPadding = { "python", "swift", "toml" },
	hrChar = "-",
	ignoreReplaceModeHelpers = { "markdown" },
}

---HELPERS----------------------------------------------------------------------

function M.setupReplaceModeHelpersForComments()
	vim.api.nvim_create_autocmd("ModeChanged", {
		desc = "User: uppercase the line when leaving replace mode on a comment",
		pattern = "r:*", -- left replace-mode
		callback = function(ctx)
			if vim.list_contains(config.ignoreReplaceModeHelpers, vim.bo[ctx.buf].ft) then return end
			local line = vim.api.nvim_get_current_line()
			local comChars = vim.trim(vim.bo.commentstring:format(""))
			if vim.startswith(vim.trim(line), comChars) then
				vim.api.nvim_set_current_line(line:upper())
			end
		end,
	})
	vim.api.nvim_create_autocmd("ModeChanged", {
		desc = "User: automatically enter replace mode at label position",
		pattern = "*:r", -- entered replace-mode
		callback = function(ctx)
			if vim.list_contains(config.ignoreReplaceModeHelpers, vim.bo[ctx.buf].ft) then return end
			local line = vim.trim(vim.api.nvim_get_current_line())
			local comChars = vim.trim(vim.bo.commentstring:format(""))
			if vim.startswith(line, comChars) then
				vim.cmd.normal { "^" .. #comChars + 1 .. "l", bang = true }
			end
		end,
	})
end

---COMMANDS---------------------------------------------------------------------

---add horizontal line with the language's comment syntax and correctly indented
---@param replaceModeLabel? any
function M.commentHr(replaceModeLabel)
	local comStr = assert(vim.bo.commentstring, "Comment string not set for " .. vim.bo.ft)
	local startLn = vim.api.nvim_win_get_cursor(0)[1]

	-- determine indent
	local ln = startLn
	local line, indent
	repeat
		line = vim.api.nvim_buf_get_lines(0, ln - 1, ln, true)[1]
		indent = line:match("^%s*")
		ln = ln - 1
	until line ~= "" or ln == 0

	-- determine hr-length
	local indentLength = vim.bo.expandtab and #indent or #indent * vim.bo.tabstop
	local comStrLength = #(comStr:format(""))
	local textwidth = vim.o.textwidth > 0 and vim.o.textwidth or 80
	local hrLength = textwidth - (indentLength + comStrLength)

	-- construct HR
	local hr = config.hrChar:rep(hrLength)
	local hrWithComment = comStr:format(hr)

	-- filetype-specific considerations
	if not vim.list_contains(config.formatterWantsPadding, vim.bo.ft) then
		hrWithComment = hrWithComment:gsub(" ", config.hrChar)
	end
	local fullLine = indent .. hrWithComment
	if vim.bo.ft == "markdown" then fullLine = "---" end

	-- append lines & move
	vim.api.nvim_buf_set_lines(0, startLn, startLn, true, { fullLine })
	if not replaceModeLabel then
		vim.api.nvim_buf_set_lines(0, startLn + 1, startLn + 1, true, { "" })
	end

	vim.api.nvim_win_set_cursor(0, { startLn + 1, #indent })
	if replaceModeLabel then
		vim.cmd.normal { comStrLength + 1 .. "l", bang = true }
		vim.cmd.startreplace()
	end
end

function M.duplicateLineAsComment()
	local comStr = assert(vim.bo.commentstring, "Comment string not set for " .. vim.bo.ft)
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()
	local indent, content = curLine:match("^(%s*)(.*)")
	local commentedLine = indent .. comStr:format(content)
	vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { commentedLine, curLine })
	vim.api.nvim_win_set_cursor(0, { lnum + 1, col })
end

---@param where? "eol"|"above"|"below"
function M.addComment(where)
	local comStr = assert(vim.bo.commentstring, "Comment string not set for " .. vim.bo.ft)
	local lnum = vim.api.nvim_win_get_cursor(0)[1]

	-- above/below: add empty line and move to it
	if where == "above" or where == "below" then
		if where == "above" then lnum = lnum - 1 end
		vim.api.nvim_buf_set_lines(0, lnum, lnum, true, { "" })
		lnum = lnum + 1
		vim.api.nvim_win_set_cursor(0, { lnum, 0 })
	end

	-- determine comment behavior
	local placeHolderAtEnd = comStr:find("%%s$") ~= nil
	local line = vim.api.nvim_get_current_line()
	local emptyLine = line == ""

	-- if empty line, add indent of first non-blank line after cursor
	local indent = ""
	if emptyLine then
		local i = lnum
		local lastLine = vim.api.nvim_buf_line_count(0)
		while vim.fn.getline(i) == "" and i < lastLine do
			i = i + 1
		end
		indent = vim.fn.getline(i):match("^%s*")
	end
	local spacing = vim.list_contains(config.formatterWantsPadding, vim.bo.ft) and "  " or " "
	local newLine = emptyLine and indent or line .. spacing

	-- write line
	local comChars = vim.trim(comStr:format(""))
	if placeHolderAtEnd then comChars = comChars .. " " end
	vim.api.nvim_set_current_line(newLine .. comChars)

	-- move cursor
	if placeHolderAtEnd then
		vim.cmd.startinsert { bang = true }
	else
		local placeholderPos = vim.bo.commentstring:find("%%s") - 1
		local newCursorPos = { lnum, #newLine + placeholderPos }
		vim.api.nvim_win_set_cursor(0, newCursorPos)
		vim.cmd.startinsert()
	end
end

--------------------------------------------------------------------------------
return M
