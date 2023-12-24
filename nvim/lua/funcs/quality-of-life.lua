local M = {}

local u = require("config.utils")

---@param cmd string
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

---@param key string
local function feedkeys(key)
	local keyCode = vim.api.nvim_replace_termcodes(key, true, false, true)
	vim.api.nvim_feedkeys(keyCode, "i", false)
end

--------------------------------------------------------------------------------

function M.commentHr()
	local commentHrChar = "─" -- CONFIG
	local wasOnBlank = vim.api.nvim_get_current_line() == ""
	local indent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch
	local comStr = vim.bo.commentstring
	local ft = vim.bo.filetype
	local comStrLength = #(comStr:gsub(" ?%%s ?", ""))

	if comStr == "" then
		u.notify("", "No commentstring for this filetype available.", "warn")
		return
	end
	if comStr:find("-") then commentHrChar = "-" end

	local commentWidth = vim.opt_local.textwidth:get()
	local linelength = commentWidth - indent - comStrLength

	-- the common formatters (black and stylelint) demand extra spaces
	local fullLine
	if ft == "css" then
		fullLine = " " .. commentHrChar:rep(linelength - 2) .. " "
	elseif ft == "python" then
		fullLine = " " .. commentHrChar:rep(linelength - 1)
	else
		fullLine = commentHrChar:rep(linelength)
	end

	-- set HR
	local hr = comStr:gsub(" ?%%s ?", fullLine)
	if ft == "markdown" then hr = "---" end

	local linesToAppend = { "", hr, "" }
	if wasOnBlank then linesToAppend = { hr, "" } end

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

function M.duplicateAsComment()
	local ln, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()
	local indent, content = curLine:match("^(%s*)(.*)")
	local commentedLine = indent .. vim.bo.commentstring:format(content)
	vim.api.nvim_buf_set_lines(0, ln - 1, ln, false, { commentedLine, curLine })
	vim.api.nvim_win_set_cursor(0, { ln + 1, col })
end

--------------------------------------------------------------------------------

function M.openAlfredPref()
	local parentFolder = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	if not parentFolder:find("Alfred%.alfredpreferences") then
		u.notify("", "Not in an Alfred directory.", "warn")
		return
	end
	-- URI seems more reliable than JXA when called via nvim https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local workflowId = parentFolder:match("Alfred%.alfredpreferences/workflows/([^/]+)")
	vim.fn.system { "open", "alfredpreferences://navigateto/workflows>workflow>" .. workflowId }
	-- in case the right workflow is already open, Alfred is not focused.
	-- Therefore manually focusing in addition to that here as well.
	vim.fn.system { "open", "-a", "Alfred Preferences" }
end

function M.openNewScope()
	local line = vim.api.nvim_get_current_line()
	local trailChar = line:match(",? *$")
	line = line:gsub(" *,? *$", "") .. " {" -- edit current line
	vim.api.nvim_set_current_line(line)
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	local indent = line:match("^%s*")
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. "\t", indent .. "}" .. trailChar })
	vim.api.nvim_win_set_cursor(0, { ln + 1, 1 }) -- go line down
	vim.cmd.startinsert { bang = true }
end

--- open the next regex at https://regex101.com/
function M.openAtRegex101()
	local lang = vim.bo.filetype
	local text, pattern, replace, flags

	if (lang == "javascript" or lang == "typescript") then
		vim.cmd.TSTextobjectSelect("@regex.outer")
		normal('"zy')
		vim.cmd.TSTextobjectSelect("@regex.inner") -- reselect for easier pasting
		text = vim.fn.getreg("z")
		pattern = text:match("/(.*)/")
		flags = text:match("/.*/(%l*)") or "gm"
		replace = vim.api.nvim_get_current_line():match('replace ?%(/.*/.*, ?"(.-)"')
	elseif (lang == "python") then
		normal('"zyi"vi"') -- yank & reselect inside quotes
		pattern = vim.fn.getreg("z")
		flags = "gm" -- TODO retrieve flags in a smarter way
	else
		u.notify("Unsupported filetype.", "warn")
		return
	end


	-- DOCS https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url = ("https://regex101.com/?regex=%s&subst=%s&flags=%s&flavor=%s"):format(
		pattern,
		(replace and "&subst=" .. replace or ""),
		flags,
		lang
	)
	vim.fn.system { "open", url }
end

-- simple task selector from makefile
function M.selectMake()
	-- GUARD
	local makefile = vim.loop.cwd() .. "/Makefile"
	local fileExists = vim.loop.fs_stat(makefile)
	if not fileExists then
		u.notify("Makefile not found", "warn")
		return
	end

	local recipes = {}
	for line in io.lines(makefile) do
		local recipe = line:match("^[%w_]+")
		if recipe then table.insert(recipes, recipe) end
	end

	vim.ui.select(recipes, { prompt = " make" }, function(selection)
		if not selection then return end
		vim.cmd("silent! lmake")
		vim.cmd.lmake(selection)
	end)
end

-- Increment, or Toggle if cursorword is true/false
-- requires `expr = true` for the keymap
function M.toggleOrIncrement()
	local cword = vim.fn.expand("<cword>")
	local bool = { ["true"] = "false", ["True"] = "False" }
	local toggle
	for word, opposite in pairs(bool) do
		if cword == word then toggle = opposite end
		if cword == opposite then toggle = word end
		if toggle then return "mzciw" .. toggle .. "<Esc>`z" end
	end
	return "<C-a>"
end

-- simplified version of neogen.nvim
-- - requires nvim-treesitter-textobjects
-- - lsp usually provides better prefills for docstrings
function M.docstring()
	local supportedFts = { "lua", "python", "javascript" }
	if not vim.tbl_contains(supportedFts, vim.bo.filetype) then
		u.notify("Unsupported filetype.", "warn")
		return
	end

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
		vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { "---" })
		vim.api.nvim_win_set_cursor(0, { ln, 0 })
		vim.cmd.startinsert { bang = true }
		-- HACK to trigger the `@param;@return` luadoc completion from lua-ls
		vim.defer_fn(function()
			require("cmp").complete()
			require("cmp").confirm { select = true }
		end, 1)
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
	end
end

---simplified implementation of tabout.nvim, to be used in insert-mode
function M.tabout()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local charsBefore = line:sub(1, col)
	local onlyWhitespaceBeforeCursor = charsBefore:match("^%s*$")
	local frontOfMarkdownList = vim.bo.ft == "markdown" and charsBefore:match("^[%s-*+]*$")

	if onlyWhitespaceBeforeCursor or frontOfMarkdownList then
		-- using feedkeys instead of `expr = true`, since the cmp mapping
		-- does not work with `expr = true`
		feedkeys("<C-t>")
	elseif vim.bo.ft == "gitcommit" then
		feedkeys("<C-e>")
	else
		local closingPairs = "[%]\"'`)}]"
		local nextClosingPairPos = line:find(closingPairs, col + 1)
		if not nextClosingPairPos then return end

		vim.cmd.stopinsert() -- INFO nvim_win_set_cursor does not work in insert mode
		vim.defer_fn(function()
			vim.api.nvim_win_set_cursor(0, { row, nextClosingPairPos })
			local isEndOfLine = nextClosingPairPos == #line

			vim.cmd.startinsert { bang = isEndOfLine }
		end, 1)
	end
end

--------------------------------------------------------------------------------
return M
