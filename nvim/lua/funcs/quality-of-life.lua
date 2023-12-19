local M = {}
local u = require("config.utils")
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

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

-- DOCS https://wezfurlong.org/wezterm/cli/cli/send-text
function M.sendToWezTerm()
	vim.fn.system([[
		open -a 'WezTerm'
		i=0
		while ! pgrep -xq wezterm-gui; do
			sleep 0.1
			i=$((i+1))
			test $i -gt 30 && return
		done
		sleep 0.2
	]])

	local text
	if vim.fn.mode() == "n" then
		text = vim.api.nvim_get_current_line() .. "\n"
		vim.fn.system { "wezterm", "cli", "send-text", "--no-paste", text }
	elseif vim.fn.mode():find("[Vv]") then
		normal('"zy')
		text = vim.fn.getreg("z"):gsub("\n$", "")
		vim.fn.system { "wezterm", "cli", "send-text", text }
	end
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

--------------------------------------------------------------------------------

--- open the next regex at https://regex101.com/
function M.openAtRegex101()
	-- copy regex to register
	vim.cmd.TSTextobjectSelect("@regex.outer")
	normal('"zy')

	-- reselect for easier pasting
	vim.cmd.TSTextobjectSelect("@regex.inner")

	local regex = vim.fn.getreg("z")
	local pattern = regex:match("/(.*)/")
	local flags = regex:match("/.*/(%l*)")
	local replacement = vim.api.nvim_get_current_line():match('replace ?%(/.*/.*, ?"(.-)"')

	-- https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url = "https://regex101.com/?regex=" .. pattern .. "&flags=" .. flags
	if replacement then url = url .. "&subst=" .. replacement end

	vim.fn.system { "open", url }
end

--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------

-- simplified version of neogen.nvim
-- requires nvim-treesitter-textobjects
function M.docstring()
	-- GUARD
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
		vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { "--" })
		vim.api.nvim_win_set_cursor(0, { ln, 0 })
		vim.cmd.startinsert { bang = true }
		-- need to manually press `-` to trigger lua-lsp completion
		-- TODO figure out how to trigger it programmatically
	elseif ft == "javascript" then
		normal("t)") -- go to parameter, since cursor has to be on diagnostic for code action
		vim.lsp.buf.code_action {
			filter = function(action) return action.title == "Infer parameter types from usage" end,
			apply = true,
		}
		-- goto docstring (delayed, so code action can finish first)
		vim.defer_fn(function ()
			vim.api.nvim_win_set_cursor(0, { ln + 1, 0 })
			normal("t}") 
		end, 100)
	end
end

--------------------------------------------------------------------------------

---simplified implementation of tabout.nvim, to be used in insert-mode
function M.tabout()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local charsBefore = line:sub(1, col)
	local onlyWhitespaceBeforeCursor = charsBefore:match("^%s*$")

	if onlyWhitespaceBeforeCursor then
		-- using feedkeys instead of `expr = true`, since the cmp mapping
		-- does not work with `expr = true`
		local key = vim.api.nvim_replace_termcodes("<C-t>", true, false, true)
		vim.api.nvim_feedkeys(key, "i", false)
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
