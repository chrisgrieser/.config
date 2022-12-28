---@diagnostic disable: param-type-mismatch, assign-type-mismatch
local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local b = vim.b
local fn = vim.fn
local cmd = vim.cmd
local getline = vim.fn.getline
local lineNo = vim.fn.line
local colNo = vim.fn.col
local append = vim.fn.append
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local expand = vim.fn.expand

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---@param option string
---@return any
local function getlocalopt(option) return vim.api.nvim_get_option_value(option, { scope = "local" }) end

---equivalent to `:setlocal option&`
---@param option string
---@return any
local function getglobalopt(option) return vim.api.nvim_get_option_value(option, { scope = "global" }) end
--------------------------------------------------------------------------------

-- Duplicate line under cursor, and change occurrences of certain words to their
-- opposite, e.g., "right" to "left". Intended for languages like CSS.
---@param opts? table available: reverse, moveTo = key|value|none, increment
function M.duplicateLine(opts)
	if not opts then opts = { reverse = false, moveTo = "key", increment = false } end

	local line = getline(".") ---@type string
	if opts.reverse then
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
	end

	if opts.increment then
		local digits = line:match("%d+")
		if digits then
			digits = tostring(tonumber(digits) + 1)
			line = line:gsub("%d+", digits, 1)
		end
	end

	append(".", line)

	-- cursor movement
	local lineNum, colNum = unpack(getCursor(0))
	lineNum = lineNum + 1 -- line down
	local keyPos, valuePos = line:find(".%w+ ?[:=] ?")
	if opts.moveTo == "value" and valuePos then
		colNum = valuePos
	elseif opts.moveTo == "key" and keyPos then
		colNum = keyPos
	end
	setCursor(0, { lineNum, colNum })
end

function M.duplicateSelection()
	local prevReg = fn.getreg("z")
	cmd([[noautocmd silent! normal!"zy`]"zp]]) -- `noautocmd` to not trigger highlighted-yank
	fn.setreg("z", prevReg)
end

--------------------------------------------------------------------------------

-- macOS only
-- https://github.com/echasnovski/mini.nvim/blob/main/doc/mini-ai.txt
function M.bettergx()
	local urlVimRegex =
		[[https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*]] -- https://gist.github.com/tobym/584909
	local urlLuaRegex = [[https?:?[^%s]+]] -- lua url regex being simple is okay, since vimregex runs before
	local prevCur = getCursor(0)

	normal("0") -- to prioritize URLs in the same line
	local urlLineNr = fn.search(urlVimRegex, "wcz")
	if urlLineNr == 0 then
		vim.notify("No URL found in this file.", logWarn)
	else
		local urlLine = fn.getline(urlLineNr) ---@type string
		local url = urlLine:match(urlLuaRegex)
		os.execute('opener "' .. url .. '"')
	end
	setCursor(0, prevCur)
end

---Close tabs, window, buffer in that order if there is more than one of the type
function M.betterClose()
	-- to not include notices in window count
	local hasNotify = pcall(require, "notify")
	if hasNotify then require("notify").dismiss() end

	-- HACK: since scrollview-like plugins counts as a window, but only appears if buffer is
	-- longer than window https://github.com/dstein64/nvim-scrollview/issues/83
	local wincount = 0
	for i = 1, fn.winnr("$"), 1 do
		local win = api.nvim_win_get_config(fn.win_getid(i))
		if not win.external and win.focusable then wincount = wincount + 1 end
	end

	local moreThanOneWin = wincount > 1
	local moreThanOneTab = fn.tabpagenr("$") > 1
	local buffers = fn.getbufinfo { buflisted = 1 }
	local unsavedFile = expand("%") == ""

	cmd.nohlsearch()
	if bo.modifiable and not unsavedFile then cmd.update() end

	if moreThanOneTab then
		cmd.tabclose()
	elseif moreThanOneWin then
		cmd.bdelete()
	elseif #buffers == 2 then
		cmd.bwipeout() -- only method to clear altfile in this case
	elseif #buffers > 1 then
		local bufToDel = expand("%:p")
		if unsavedFile then
			cmd.bwipeout()
		else
			cmd.bdelete()
		end

		-- ensure new alt file points towards open, non-active buffer
		local curFile = expand("%:p")
		local i = 0
		local newAltBuf
		repeat
			i = i + 1
			newAltBuf = buffers[i].name
		until newAltBuf ~= curFile and newAltBuf ~= bufToDel

		fn.setreg("#", newAltBuf)
	else
		vim.notify("Only one buffer open.", logWarn)
	end
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
	local resetLabel = "last open (~" .. tostring(minsPassed) .. "m ago)"
	local selection = { resetLabel, "15m", "1h", "4h", "24h" }

	vim.ui.select(selection, { prompt = "Undo the last…" }, function(choice)
		if not choice then
			return
		elseif choice:find("last open") then
			cmd("earlier " .. minsPassed .. "m")
		else
			cmd("earlier " .. choice)
		end
		vim.notify("Restored to " .. choice .. " earlier.")
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
	local wrapOn = getlocalopt("wrap")
	local opts = { buffer = true }
	if wrapOn then
		setlocal("wrap", false) -- soft wrap
		setlocal("colorcolumn", getglobalopt("colorcolumn")) -- deactivate ruler

		local del = vim.keymap.del
		del({ "n", "x" }, "H", opts)
		del({ "n", "x" }, "L", opts)
		del({ "n", "x" }, "J", opts)
		del({ "n", "x" }, "K", opts)
		del({ "n", "x" }, "k", opts)
		del({ "n", "x" }, "j", opts)
	else
		setlocal("wrap", true) -- soft wrap
		setlocal("colorcolumn", "") -- deactivate ruler

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

-- common shell options for fn.jobstart()
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
			{ "chore", "built", "test", "fix", "feat", "refactor", "perf", "style", "revert", "ci", "docs" }
		local firstWord = commitMsg:match("^%w+")
		if not vim.tbl_contains(cc, firstWord) then
			vim.notify("Not using a Conventional Commits keyword.", logWarn)
			M.addCommitPush(commitMsg)
			return
		end

		vim.notify("ﴻ add-commit-push…")
		fn.jobstart("git add -A && git commit -m '" .. commitMsg .. "' ; git pull ; git push", shellOpts)
	end)
end

function M.gitLink()
	local repo = fn.system([[git remote -v]]):gsub(".*:(.-) %(.*", "%1")
	local branch = fn.system([[git branch --show-current]]):gsub("\n", "")
	if branch:find("^fatal: not a git repository") then
		vim.notify("Not a git repository.", logWarn)
		return
	end
	local filepath = expand("%:p")
	local gitroot = fn.system([[git rev-parse --show-toplevel]])
	local pathInRepo = filepath:sub(#gitroot)

	local location
	local selStart = fn.line("v")
	local selEnd = fn.line(".")
	if selStart == selEnd then -- normal mode or one-line-selection
		location = "L" .. tostring(selStart)
	elseif selStart < selEnd then
		location = "L" .. tostring(selStart) .. "-L" .. tostring(selEnd)
	else
		location = "L" .. tostring(selEnd) .. "-L" .. tostring(selStart)
	end

	local gitRemote = "https://github.com/" .. repo .. "/blob/" .. branch .. pathInRepo .. "#" .. location

	os.execute("open '" .. gitRemote .. "'")
	fn.setreg("+", gitRemote)
end
--------------------------------------------------------------------------------

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.quicklog()
	local varname
	if fn.mode() == "n" then
		varname = fn.expand("<cword>")
	else
		local prevReg = fn.getreg("z")
		normal('"zy')
		varname = fn.getreg("z")
		fn.setreg("z", prevReg)
	end

	local logStatement
	local ft = bo.filetype
	local lnStr = ""

	if ft == "lua" then
		logStatement = 'print("' .. lnStr .. varname .. ':", ' .. varname .. ")"
	elseif ft == "python" then
		logStatement = 'print("' .. lnStr .. varname .. ': " + ' .. varname .. ")"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("' .. lnStr .. varname .. ': " + ' .. varname .. ");"
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logStatement = 'echo "' .. lnStr .. varname .. ": $" .. varname .. '"'
	elseif ft == "applescript" then
		logStatement = 'log "' .. lnStr .. varname .. ': " & ' .. varname
	else
		vim.notify("Quicklog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(".", logStatement)
	normal("j==")
end

function M.timelog()
	if not g.timelogCount then g.timelogCount = 0 end
	local logStatement1, logStatement2
	local ft = bo.filetype

	if ft == "lua" then
		logStatement1 = {
			'print("timelog start")',
			"local timelogStart = os.time()",
		}
		logStatement2 = {
			"local duration = os.difftime(timelogStart, os.time())",
			'print("timelog: ", duration)',
		}
	elseif ft == "javascript" or ft == "typescript" then
		logStatement1 = 'console.time("timelog")'
		logStatement2 = 'console.timeEnd("timelog")'
	else
		vim.notify("Timelog does not support " .. ft .. " yet.", logWarn)
		return
	end
	local logToAdd = (g.timelogCount % 2 == 0) and logStatement1 or logStatement2

	append(".", logToAdd)
	for _ = 1, #logToAdd, 1 do
		normal("j==")
	end
	g.timelogCount = g.timelogCount + 1
end

---adds simple "beep" log statement to check whether conditionals have been
--entered Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.beeplog()
	local logStatement
	local ft = bo.filetype

	if ft == "lua" or ft == "python" then
		logStatement = 'print("beep")'
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("beep")'
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logStatement = 'echo "beep"'
	elseif ft == "applescript" then
		logStatement = 'log "beep"'
	else
		vim.notify("Beeplog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(".", logStatement)
	normal("j==")
end

---Remove all log statements in the current buffer
---Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.removelogs()
	local ft = bo.filetype
	local logCommand
	local linesBefore = fn.line("$")
	if ft == "lua" or ft == "python" then
		logCommand = "print"
	elseif ft == "javascript" or ft == "typescript" then
		logCommand = "console."
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		vim.notify("Shell 'echo' cannot be removed since indistinguishable from other echos.", logWarn)
	elseif ft == "applescript" then
		logCommand = "log"
	else
		vim.notify("Removelog does not support " .. ft .. " yet.", logWarn)
	end

	cmd([[g/^\s*]] .. logCommand .. [[/d]])
	cmd.nohlsearch()

	local linesRemoved = linesBefore - fn.line("$")
	local msg = "Cleared " .. tostring(linesRemoved) .. " log statements."
	if linesRemoved == 1 then msg = msg:gsub("s%.$", ".") end
	vim.notify(msg)
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
