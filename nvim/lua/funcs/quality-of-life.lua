local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local b = vim.b
local fn = vim.fn
local cmd = vim.cmd
local lineNo = vim.fn.line
local colNo = vim.fn.col
local append = vim.fn.append
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local expand = vim.fn.expand

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---equivalent to fn.getline(), but using more efficient nvim api
---@param lnum integer|string
---@return string
local function getline(lnum)
	local arg
	if type(lnum) == "number" then
		arg = lnum
	elseif lnum == "." then
		local curRow = getCursor(0)[1]
		arg = curRow
	else
		return ""
	end
	local lineContent = vim.api.nvim_buf_get_lines(0, arg - 1, arg, true)
	return lineContent[1]
end

---equivalent to `:setlocal option&`
---@param option string
---@return any
function getlocal(option) return vim.api.nvim_get_option_value(option, { scope = "local" }) end

---equivalent to `:setlocal option=value`
---@param option string
---@param value any
function setlocal(option, value)
	-- :setlocal does not have a direct access via the vim-module, it seems https://neovim.io/doc/user/lua.html#lua-vim-setlocal
	vim.api.nvim_set_option_value(option, value, { scope = "local" })
end


--------------------------------------------------------------------------------

-- Duplicate line under cursor, change occurrences of certain words to their
-- opposite, e.g., "right" to "left", and move cursor to key is there is one
function M.cssDuplicateLine()
	local line = getline(".")

	if line:find("top") then
		line = line:gsub("top", "bottom")
	elseif line:find("bottom") then
		line = line:gsub("bottom", "top")
	elseif line:find("right") then
		line = line:gsub("right", "left")
	elseif line:find("left") then
		line = line:gsub("left", "right")
	elseif line:find("height") and not (line:find("line-height")) then
		line = line:gsub("height", "width")
	elseif line:find("width") and not (line:find("border-width")) and not (line:find("outline-width")) then
		line = line:gsub("width", "height")
	end

	append(".", line) ---@diagnostic disable-line: param-type-mismatch

	-- cursor moved to key if there is one
	local lineNum, colNum = unpack(getCursor(0))
	lineNum = lineNum + 1 -- line down
	local keyPos = line:find(".%w+ ?: ?")
	if keyPos then colNum = keyPos end
	setCursor(0, { lineNum, colNum })
end

-- Duplicate line under cursor, smartly change words like "if" to "elseif",
-- and if there is a variable assignment with a numbered variable like "item1",
-- then increment the number. If there is a variable assignment or key-value
-- pair, move to the key
function M.smartDuplicateLine()
	local line = getline(".")
	local ft = bo.filetype

	-- smart switching of conditionals
	if ft == "lua" and line:find("^%s*if.+then$") then
		line = line:gsub("^(%s*)if", "%1elseif")
	elseif (ft == "bash" or ft == "zsh" or ft == "sh") and line:find("^%s*if.+then$") then
		line = line:gsub("^(%s*)if", "%1elif")
	elseif (ft == "javascript" or ft == "typescript") and line:find("^%s*if.+{$") then
		line = line:gsub("^(%s*)if", "%1} else if")
	end

	-- increment numbered vars
	local lineHasNumberedVarAssignment, _, num = line:find("(%d+).*=")
	if lineHasNumberedVarAssignment then
		local nextNum = tostring(tonumber(num) + 1)
		line = line:gsub("%d+(.*=)", nextNum .. "%1")
	end

	append(".", line) ---@diagnostic disable-line: param-type-mismatch

	-- cursor movement to value if there is one
	local lineNum, colNum = unpack(getCursor(0))
	lineNum = lineNum + 1 -- line down
	local _, valuePos = line:find(".%w+ ?[:=] ?")
	if valuePos then colNum = valuePos end
	setCursor(0, { lineNum, colNum })
end

function M.duplicateSelection()
	local prevReg = fn.getreg("z")
	cmd([[noautocmd silent! normal!"zy`]"zp]]) -- `noautocmd` to not trigger highlighted-yank
	fn.setreg("z", prevReg)
end

--------------------------------------------------------------------------------

---switches words under the cursor from `true` to `false` and similar cases
function M.wordSwitch()
	local iskeywBefore = opt.iskeyword:get()
	opt.iskeyword:remove { "_", "-", "." }

	local words = {
		{ "true", "false" },
		{ "<=", ">=" },
		{ "on", "off" },
		{ "yes", "no" },
		{ "disable", "enable" },
		{ "disabled", "enabled" },
		{ "show", "hide" },
		{ "right", "left" },
		{ "top", "bottom" },
		{ "width", "height" },
		{ "relative", "absolute" },
		{ "dark", "light" },
		{ "and", "or" },
	}
	local ft = bo.filetype
	local ftWords -- 3rd item false if 2nd item shouldn't also switch to first
	if ft == "lua" then
		ftWords = {
			{ "~=", "==" },
			{ "if", "elseif", false },
			{ "elseif", "else", false },
			{ "else", "if", false },
			{ "function", "local function", false },
			{ "pairs", "ipairs" },
		}
	elseif ft == "python" then
		ftWords = {
			{ "True", "False" },
		}
	elseif ft == "bash" or ft == "zsh" or ft == "sh" then
		ftWords = {
			{ "-eq", "-ne" },
			{ "||", "&&" },
			{ "if", "elif", false },
			{ "elif", "else", false },
			{ "else", "if", false },
			{ "echo", "print" },
			{ "exit", "return" },
		}
	elseif ft == "javascript" or ft == "typescript" then
		ftWords = {
			{ "!==", "===" },
			{ "||", "&&" },
			{ "if", "else if", false },
			{ "else", "if", false },
			{ "const", "let" },
			{ "replace", "replaceAll" },
		}
	end
	if ftWords then
		for _, item in pairs(ftWords) do
			table.insert(words, item)
		end
	end

	local cword = expand("<cword>")
	local newWord = nil
	for _, pair in pairs(words) do
		if cword == pair[1] then
			newWord = pair[2]
			break
		elseif cword == pair[2] and pair[3] ~= false then
			newWord = pair[1]
			break
		end
	end

	if newWord then
		fn.setreg("z", newWord) -- HACK no idea why, but ciw does not work well with normal, therefore pasting instead
		normal([[viw"zP]])
	else
		vim.notify("Word under cursor cannot be switched.", vim.log.levels.WARN)
	end

	opt.iskeyword = iskeywBefore
end

--------------------------------------------------------------------------------
-- UNDO

-- Save Open time
augroup("undoTimeMarker", {})
autocmd("BufReadPost", {
	group = "undoTimeMarker",
	callback = function() b.timeOpened = os.time() end,
})

---select between undoing the last 1h, 4h, or 24h
function M.undoDuration()
	local now = os.time() -- saved in epoch secs
	local minsPassed = math.floor((now - b.timeOpened) / 60)
	local resetLabel = "~" .. tostring(minsPassed) .. "m ago)"
	local selection = { resetLabel, "15m", "1h", "4h", "24h", " present" }

	vim.ui.select(selection, { prompt = "Undo…" }, function(choice)
		if not choice then
			return
		elseif choice:find("ago") then
			cmd.earlier(minsPassed .. "m")
		elseif choice:find("present") then
			cmd.later(tostring(opt.undolevels:get())) -- redo as much as there are undolevels
		else
			cmd.earlier(choice)
		end
	end)
end

--------------------------------------------------------------------------------

---enables overscrolling for that action when close to the last line, depending
---on 'scrolloff' option
---@param action string The motion to be executed when not at the EOF
function M.overscroll(action)
	if bo.filetype ~= "DressingSelect" then
		local curLine = lineNo(".")
		local lastLine = lineNo("$")
		if (lastLine - curLine) <= vim.wo.scrolloff then normal("zz") end
	end

	local usedCount = vim.v.count1
	local actionCount = action:match("%d+") -- if action includes a count
	if actionCount then
		action = action:gsub("%d+", "")
		usedCount = tonumber(actionCount) * usedCount
	end
	normal(tostring(usedCount) .. action)
end

---toggle wrap, colorcolumn, and hjkl visual/logical maps in one go
function M.toggleWrap()
	local wrapOn = getlocal("wrap")
	local opts = { buffer = true }

	if wrapOn then
		setlocal("wrap", false)
		setlocal("colorcolumn", o.colorcolumn)

		local del = vim.keymap.del
		del({ "n", "x" }, "H", opts)
		del({ "n", "x" }, "L", opts)
		del({ "n", "x" }, "J", opts)
		del({ "n", "x" }, "K", opts)
		del({ "n", "x" }, "k", opts)
		del({ "n", "x" }, "j", opts)
	else
		setlocal("wrap", true)
		setlocal("colorcolumn", "")

		local keymap = vim.keymap.set
		keymap({ "n", "x" }, "H", "g^", opts)
		keymap({ "n", "x" }, "L", "g$", opts)
		keymap({ "n", "x" }, "J", function() M.overscroll("6gj") end, opts)
		keymap({ "n", "x" }, "K", "6gk", opts)
		keymap({ "n", "x" }, "k", "gk", opts)
		keymap({ "n", "x" }, "j", function() M.overscroll("gj") end, opts)
	end
end

--------------------------------------------------------------------------------
-- GIT

-- options for fn.jobstart()
local shellOpts = {
	stdout_buffered = true,
	stderr_buffered = true,
	detach = true,
	on_stdout = function(_, data, _)
		if not data or (data[1] == "" and #data == 1) then return end
		local stdOut = table.concat(data, " \n "):gsub("%s*$", "")
		vim.notify(stdOut)
	end,
	on_stderr = function(_, data, _)
		if not data or (data[1] == "" and #data == 1) then return end
		local stdErr = table.concat(data, " \n "):gsub("%s*$", "")
		vim.notify(stdErr)
	end,
}

---@param prefillMsg? string
function M.addCommitPush(prefillMsg)
	if not prefillMsg then prefillMsg = "" end

	-- uses dressing + cmp + omnifunc for autocompletion of filenames
	vim.ui.input({ prompt = "Commit Message", default = prefillMsg, completion = "file" }, function(commitMsg)
		if not commitMsg then
			return
		elseif #commitMsg > 50 then
			vim.notify("Commit Message too long.", logWarn)
			M.addCommitPush(commitMsg:sub(1, 50))
			return
		elseif commitMsg == "" then
			commitMsg = "chore"
		end

		local cc =
			{ "chore", "build", "test", "fix", "feat", "refactor", "perf", "style", "revert", "ci", "docs" }
		local firstWord = commitMsg:match("^%w+")
		if not vim.tbl_contains(cc, firstWord) then
			vim.notify("Not using a Conventional Commits keyword.", logWarn)
			M.addCommitPush(commitMsg)
			return
		end

		vim.notify(' git add-commit-push\n"' .. commitMsg .. '"')
		fn.jobstart("git add -A && git commit -m '" .. commitMsg .. "' ; git pull ; git push", shellOpts)
	end)
end

function M.gitLink()
	local repo = fn.system([[git --no-optional-locks remote -v]]):gsub(".*:(.-)%.git .*", "%1")
	local branch = fn.system([[git --no-optional-locks branch --show-current]]):gsub("\n", "")
	if branch:find("^fatal: not a git repository") then
		vim.notify("Not a git repository.", logWarn)
		return
	end
	local filepath = expand("%:p")
	local gitroot = fn.system([[git --no-optional-locks rev-parse --show-toplevel]])
	local pathInRepo = filepath:sub(#gitroot)

	local location
	local selStart = fn.line("v")
	local selEnd = fn.line(".")
	local notVisualMode = not (fn.mode():find("[Vv]"))
	if notVisualMode then
		location = "" -- link just the file itself
	elseif selStart == selEnd then -- one-line-selection
		location = "#L" .. tostring(selStart)
	elseif selStart < selEnd then
		location = "#L" .. tostring(selStart) .. "-L" .. tostring(selEnd)
	else
		location = "#L" .. tostring(selEnd) .. "-L" .. tostring(selStart)
	end

	local gitRemote = "https://github.com/" .. repo .. "/blob/" .. branch .. pathInRepo .. location

	os.execute("open '" .. gitRemote .. "'")
	fn.setreg("+", gitRemote)
end

--------------------------------------------------------------------------------
-- MOVEMENT
-- performed via `:normal` makes them less glitchy

local function leaveVisualMode()
	-- https://github.com/neovim/neovim/issues/17735#issuecomment-1068525617
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

function M.moveLineDown()
	if lineNo(".") == lineNo("$") then return end
	cmd([[. move +1]])
	if bo.filetype ~= "yaml" then normal("==") end
end

function M.moveLineUp()
	if lineNo(".") == 1 then return end
	cmd([[. move -2]])
	if bo.filetype ~= "yaml" then normal("==") end
end

function M.moveCharRight()
	if colNo(".") >= colNo("$") - 1 then return end
	normal('"zx"zp')
end

function M.moveCharLeft()
	if colNo(".") == 1 then return end
	normal('"zdh"zph')
end

function M.moveSelectionDown()
	leaveVisualMode()
	cmd([['<,'> move '>+1]])
	normal("gv=gv")
end

function M.moveSelectionUp()
	leaveVisualMode()
	cmd([['<,'> move '<-2]])
	normal("gv=gv")
end

function M.moveSelectionRight() normal('"zx"zpgvlolo') end

function M.moveSelectionLeft() normal('"zdh"zPgvhoho') end

--------------------------------------------------------------------------------

return M
