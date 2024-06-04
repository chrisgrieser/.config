local M = {}

---@param cmd string
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

---@return string?
local function getCommentstr()
	if vim.bo.commentstring == "" then
		vim.notify("No commentstring for " .. vim.bo.ft, vim.log.levels.WARN, { title = "Comment" })
		return
	end
	return vim.bo.commentstring
end

--------------------------------------------------------------------------------

-- appends a horizontal line, with the language's comment syntax,
-- correctly indented and padded
function M.commentHr()
	local comStr = getCommentstr()
	if not comStr then return end
	local startLn = vim.api.nvim_win_get_cursor(0)[1]

	-- determine indent
	local ln = startLn
	local line, indent
	repeat
		line = vim.api.nvim_buf_get_lines(0, ln - 1, ln, true)[1]
		indent = line:match("^%s*")
		ln = ln - 1
	until line ~= "" or ln == 0

	-- determine hrLength
	local indentLength = vim.bo.expandtab and #indent or #indent * vim.bo.tabstop
	local comStrLength = #(comStr:format(""))
	local textwidth = vim.o.textwidth > 0 and vim.o.textwidth or 80
	local hrLength = textwidth - (indentLength + comStrLength)

	-- construct hr
	local hrChar = comStr:find("%-") and "-" or "─"
	local hr = hrChar:rep(hrLength)
	local hrWithComment = comStr:format(hr)

	-- filetype-specific
	local formatterWantPadding = { "python", "css", "scss" }
	if vim.bo.filetype == "markdown" then
		hrWithComment = "---"
	elseif not vim.tbl_contains(formatterWantPadding, vim.bo.filetype) then
		hrWithComment = hrWithComment:gsub(" ", hrChar)
	end
	local fullLine = indent .. hrWithComment

	-- append lines & move
	vim.api.nvim_buf_set_lines(0, startLn, startLn, true, { fullLine, "" })
	vim.api.nvim_win_set_cursor(0, { startLn + 1, #indent })
end

function M.duplicateLineAsComment()
	local comStr = getCommentstr()
	if not comStr then return end

	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()
	local indent, content = curLine:match("^(%s*)(.*)")
	local commentedLine = indent .. comStr:format(content)
	vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { commentedLine, curLine })
	vim.api.nvim_win_set_cursor(0, { lnum + 1, col })
end

-- simplified implementation of neogen.nvim
-- (reason: lsp usually provides better prefills for docstrings)
function M.docstring()
	vim.cmd.TSTextobjectGotoPreviousStart("@function.outer")

	local ft = vim.bo.filetype
	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local ln = vim.api.nvim_win_get_cursor(0)[1]

	if ft == "python" then
		indent = indent .. (" "):rep(4)
		vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. ('"'):rep(6) })
		vim.api.nvim_win_set_cursor(0, { ln + 1, #indent + 3 })
		vim.cmd.startinsert()
	elseif ft == "lua" then
		-- PENDING https://github.com/LuaLS/lua-language-server/issues/2517
		vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { indent .. "--" })
		vim.api.nvim_win_set_cursor(0, { ln, 0 })
		-- HACK to trigger the `@param;@return` luadoc completion from lua-ls
		vim.defer_fn(function() vim.cmd.startinsert { bang = true } end, 200)
		-- vim.defer_fn(require("cmp").complete, 400)
		-- vim.defer_fn(function() require("cmp").confirm { select = true } end, 600)
	elseif ft == "javascript" then
		normal("t)") -- go to parameter, since cursor has to be on diagnostic for code action
		vim.lsp.buf.code_action {
			filter = function(action) return action.title == "Infer parameter types from usage" end,
			apply = true,
		}
		-- goto docstring (delayed, so code action can finish first)
		vim.defer_fn(function()
			vim.api.nvim_win_set_cursor(0, { ln + 1, 0 })
			normal("t}")
		end, 100)
	elseif ft == "typescript" then
		vim.lsp.buf.code_action {
			filter = function(action) return action.title == "Infer function return type" end,
			apply = true,
		}
		-- add TSDoc
		vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { indent .. "/**  */" })
		vim.api.nvim_win_set_cursor(0, { ln, #indent + 4 })
		vim.cmd.startinsert()
	else
		vim.notify("Unsupported filetype.", vim.log.levels.WARN)
	end
end

--------------------------------------------------------------------------------

---@param where "eol" | "above" | "below"
function M.addComment(where)
	-- get base values
	local comStr = getCommentstr()
	if not comStr then return end
	local lnum = vim.api.nvim_win_get_cursor(0)[1]

	-- above/below: add empty line and move to it
	if where == "above" or where == "below" then
		if where == "above" then lnum = lnum - 1 end
		vim.api.nvim_buf_set_lines(0, lnum, lnum, true, { "" })
		lnum = lnum + 1
		vim.api.nvim_win_set_cursor(0, { lnum, 0 })
	end

	-- determine comment behavior
	local placeHolderAtEnd = comStr:match("%%s$") ~= nil
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
	local newLine = emptyLine and indent or line .. " "

	-- write line
	comStr = comStr:gsub("%%s", ""):gsub(" $", "") .. " "
	vim.api.nvim_set_current_line(newLine .. comStr)

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
