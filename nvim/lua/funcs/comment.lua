local M = {}

---@param cmd string
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end
--------------------------------------------------------------------------------

-- appends a horizontal line, with the language's comment syntax,
-- correctly indented and padded
function M.commentHr()
	local comStr = vim.bo.commentstring
	if comStr == "" then
		vim.notify("Commentstring not set.", vim.log.levels.WARN)
		return
	end

	local isOnBlank = vim.api.nvim_get_current_line() == ""
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

	local formatterWantPadding = { "python", "css", "scss" }
	if not vim.tbl_contains(formatterWantPadding, vim.bo.ft) then
		hrWithComment = hrWithComment:gsub(" ", hrChar)
	end

	local fullLine = indent .. hrWithComment
	if vim.bo.ft == "markdown" then fullLine = "---" end

	-- append Lines & move
	local linesToAppend = isOnBlank and { fullLine, "" } or { "", fullLine, "" }
	vim.api.nvim_buf_set_lines(0, startLn, startLn, true, linesToAppend)
	vim.api.nvim_win_set_cursor(0, { startLn + #linesToAppend - 1, #indent })
end

function M.duplicateLineAsComment()
	local ln, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()
	local indent, content = curLine:match("^(%s*)(.*)")
	local commentedLine = indent .. vim.bo.commentstring:format(content)
	vim.api.nvim_buf_set_lines(0, ln - 1, ln, false, { commentedLine, curLine })
	vim.api.nvim_win_set_cursor(0, { ln + 1, col })
end

-- https://jupytext.readthedocs.io/en/latest/formats-scripts.html#the-percent-format
function M.insertDoublePercentCom()
	if vim.bo.commentstring == "" then return end

	local curLine = vim.api.nvim_get_current_line()
	local doublePercentCom = vim.bo.commentstring:format("%%")
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	if curLine == "" then
		vim.api.nvim_set_current_line(doublePercentCom)
		ln = ln - 1
	else
		vim.api.nvim_buf_set_lines(0, ln, ln, false, { doublePercentCom })
	end

	vim.api.nvim_buf_add_highlight(0, 0, "DiagnosticVirtualTextHint", ln, 0, -1)
end

function M.removeDoublePercentComs()
	if vim.bo.commentstring == "" then return end
	local cursorBefore = vim.api.nvim_win_get_cursor(0)
	local doublePercentCom = vim.bo.commentstring:format("%%")

	vim.cmd("% substitute/" .. doublePercentCom .. "//")

	vim.api.nvim_win_set_cursor(0, cursorBefore)
end

--------------------------------------------------------------------------------

-- simplified implementation of neogen.nvim
-- * requires nvim-treesitter-textobjects
-- * lsp usually provides better prefills for docstrings
function M.docstring()
	local ft = vim.bo.filetype
	vim.cmd.TSTextobjectGotoPreviousStart("@function.outer")

	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local ln = vim.api.nvim_win_get_cursor(0)[1]

	if ft == "python" then
		indent = indent .. (" "):rep(4)
		vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. ('"'):rep(6) })
		vim.api.nvim_win_set_cursor(0, { ln + 1, #indent + 3 })
		vim.cmd.startinsert()
	elseif ft == "lua" then
		-- PENDING https://github.com/LuaLS/lua-language-server/issues/2517
		vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { indent .. "---" })
		vim.api.nvim_win_set_cursor(0, { ln, 0 })
		vim.cmd.startinsert { bang = true }
		-- HACK to trigger the `@param;@return` luadoc completion from lua-ls
		vim.defer_fn(function()
			require("cmp").complete()
			require("cmp").confirm { select = true }
		end, 150)
		vim.defer_fn(vim.api.nvim_del_current_line, 600) -- remove `---comment`
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
		vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { indent .. "/**  */" })
		vim.api.nvim_win_set_cursor(0, { ln, #indent + 4 })
		vim.cmd.startinsert()
	else
		vim.notify("Unsupported filetype.", vim.log.levels.WARN)
	end
end
--------------------------------------------------------------------------------
return M
