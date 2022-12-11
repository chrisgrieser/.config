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
local logWarn = vim.log.levels.WARN
local function wordUnderCursor()
	return vim.fn.expand("<cword>")
end

local function leaveVisualMode()
	-- https://github.com/neovim/neovim/issues/17735#issuecomment-1068525617
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

---trims whitespace from string
---@param str string
---@return string
function trim(str)
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------

---Copy Last Command
function M.copyLastCommand()
	local reg = '"'
	local clipboardOpt = vim.opt.clipboard:get();
	local useSystemClipb = #clipboardOpt > 0 and clipboardOpt[1]:find("unnamed")
	if useSystemClipb then reg = "+" end

	local lastCommand = fn.getreg(":")
	if not (lastCommand) then
		vim.notify(" No Command has been run yet. ", logWarn)
		return
	end
	fn.setreg(reg, lastCommand)
	vim.notify(" COPIED\n " .. lastCommand)
end

--------------------------------------------------------------------------------

-- Duplicate line under cursor, and change occurrences of certain words to their
-- opposite, e.g., "right" to "left". Intended for languages like CSS.
---@param opts? table available: reverse, moveTo = key|value|none, increment
function M.duplicateLine(opts)
	if not (opts) then
		opts = {reverse = false, moveTo = "key", increment = false}
	end

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
	local lineNum = getCursor(0)[1] + 1 -- line down
	local colNum = getCursor(0)[2]
	local keyPos, valuePos = line:find(".%w+ ?[:=] ?")
	if opts.moveTo == "value" and valuePos then
		colNum = valuePos
	elseif opts.moveTo == "key" and keyPos then
		colNum = keyPos
	end
	setCursor(0, {lineNum, colNum})
end

function M.duplicateSelection()
	local prevReg = fn.getreg("z")
	cmd [[noautocmd silent! normal!"zy`]"zp]] -- `noautocmd` to not trigger highlighted-yank
	fn.setreg("z", prevReg)
end

--------------------------------------------------------------------------------

-- macOS only
-- https://github.com/echasnovski/mini.nvim/blob/main/doc/mini-ai.txt
function M.bettergx()
	local urlVimRegex = [[https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*]] -- https://gist.github.com/tobym/584909
	local urlLuaRegex = [[https?:?[^%s]+]] -- lua url regex being simple is okay, since vimregex runs before
	local prevCur = getCursor(0)

	cmd.normal {"0", bang = true} -- to prioritize URLs in the same line
	local urlLineNr = fn.search(urlVimRegex, "wcz")
	if urlLineNr == 0 then
		vim.notify(" No URL found in this file. ", logWarn)
	else
		local urlLine = fn.getline(urlLineNr) ---@type string
		local url = urlLine:match(urlLuaRegex)
		local opener
		if fn.has("macunix") then
			opener = "open"
		elseif fn.has("unix") then
			opener = "xdg-open"
		elseif fn.has("win64") or fn.has("win32") then
			opener = "start"
		end
		if opener then
			os.execute(opener .. ' "' .. url .. '"')
		else
			vim.notify(" Sorry, you have some arcane operating system that is not supported yet. ", logWarn)
		end
	end
	setCursor(0, prevCur)
end

---Close tabs, window, buffer in that order if there is more than one of the type
function M.betterClose()
	local hasNotify = pcall(require, "notify")
	if hasNotify then require("notify").dismiss() end -- to not include notices in window count

	-- HACK: since scrollview counts as a window, but only appears if buffer is
	-- longer than window https://github.com/dstein64/nvim-scrollview/issues/83
	local threshold
	local hasScrollview = pcall(require, "scrollview")
	if hasScrollview then
		local bufHeight = fn.line("$")
		local winHeight = api.nvim_win_get_height(0)
		threshold = bufHeight <= winHeight and 1 or 2
	else
		threshold = 1
	end
	local moreThanOneWin = fn.winnr("$") > threshold

	local moreThanOneTab = fn.tabpagenr("$") > 1
	local buffers = fn.getbufinfo {buflisted = 1}

	cmd.nohlsearch()
	cmd.update()
	if moreThanOneTab then
		cmd.tabclose()
	elseif moreThanOneWin then
		if bo.filetype == "" then cmd.bwipeout() end -- scratch buffers
		cmd.close()
	elseif #buffers == 2 then
		cmd.bwipeout() -- only method to clear altfile in this case
	elseif #buffers > 1 then
		local bufToDel = fn.expand("%:p")
		cmd.bdelete()

		-- ensure new alt file points towards open, non-active buffer
		local curFile = fn.expand("%:p")
		local i = 1
		local newAltBuf
		repeat
			i = i + 1
			newAltBuf = buffers[i].name
		until newAltBuf ~= curFile and newAltBuf ~= bufToDel

		fn.setreg("#", newAltBuf)
	else
		vim.notify(" Only one buffer open. ", logWarn)
	end
end

--------------------------------------------------------------------------------
-- UNDO
-- Save
augroup("undoTimeMarker", {})
autocmd("BufReadPost", {
	group = "undoTimeMarker",
	callback = function() b.timeOpened = os.time() end,
})

---select between undoing the last 1h, 4h, or 24h
---@param opts table
function M.undoDuration(opts)
	local now = os.time()
	local secsPassed = now - b.timeOpened
	local minsPassedStr = tostring(secsPassed / 60)
	local resetLabel = "last save (" .. minsPassedStr .. "m ago)"
	if not (opts) then opts = {selection = {resetLabel, "15m", "1h", "4h", "24h"}} end
	vim.ui.select(opts.selection, {prompt = "Undo the last…"}, function(choice)
		if not (choice) then return end
		if choice:find("last save") then
			cmd("earlier " .. secsPassed .. "s")
		else
			cmd("earlier " .. choice)
		end
		vim.notify(" Restored to " .. choice .. " earlier. ")
	end)
end

--------------------------------------------------------------------------------

---enables overscrolling for that action when close to the last line, depending
--on 'scrolloff' option
---@param action string The motion to be executed when not at the EOF
function M.overscroll(action)
	if bo.filetype ~= "DressingSelect" then
		local curLine = lineNo(".")
		local lastLine = lineNo("$")
		if (lastLine - curLine) <= vim.wo.scrolloff then
			cmd [[normal! zz]]
		end
	end
	cmd("normal! " .. tostring(vim.v.count1) .. action)
end

---Force pasting a linewise register characterwise and vice versa
---@param opts? table
function M.pasteDifferently(opts) -- paste as characterwise
	if not (opts) then opts = {reg = "+"} end
	local reg = opts.reg

	local isLinewise = fn.getregtype(reg) == "V"
	local isCharwise = fn.getregtype(reg) == "v"
	local regContent = fn.getreg(reg)
	regContent = trim(regContent)
	local targetRegType

	if isLinewise then
		targetRegType = "v"
	elseif isCharwise then
		targetRegType = "V"
	else
		vim.notify(" This paste command does not work with blockwise registers.", logWarn)
		return
	end

	fn.setreg(reg, regContent, targetRegType)
	cmd('normal! "' .. reg .. "p")
	if targetRegType == "V" then cmd [[normal!==]] end -- indent the new paste
end

--------------------------------------------------------------------------------

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
---@param opts? table
function M.quicklog(opts)
	if not (opts) then opts = {addLineNumber = false} end

	local varname = wordUnderCursor()
	local logStatement
	local ft = bo.filetype
	local lnStr = ""
	if opts.addLineNumber then
		lnStr = "L" .. tostring(lineNo(".")) .. " "
	end

	if ft == "lua" then
		logStatement = 'print("' .. lnStr .. varname .. ':", ' .. varname .. ")"
	elseif ft == "python" then
		logStatement = 'print("' .. lnStr .. varname .. ': " + ' .. varname .. ")"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("' .. lnStr .. varname .. ': " + ' .. varname .. ");"
	elseif ft == "zsh" or ft == "bash" or ft == "fish" then
		logStatement = 'echo "' .. lnStr .. varname .. ": $" .. varname .. '"'
	elseif ft == "applescript" then
		logStatement = 'log "' .. lnStr .. varname .. ': " & ' .. varname
	else
		vim.notify(" Quicklog does not support " .. ft .. " yet.", logWarn)
	end

	append(".", logStatement)
	cmd [[normal! j==]] -- move down and indent
end

---Remove all log statements in the current buffer
---Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.removeLog()
	local ft = bo.filetype
	local logCommand
	if ft == "lua" or ft == "python" then
		logCommand = "print"
	elseif ft == "javascript" or ft == "typescript" then
		logCommand = "console."
	elseif ft == "zsh" or ft == "bash" or ft == "fish" then
		vim.notify(" Shell 'echo' cannot be removed since indistinguishable from other echos. ", logWarn)
	elseif ft == "applescript" then
		logCommand = "log"
	else
		vim.notify(" Quicklog does not support " .. ft .. " yet.")
	end
	local logsStatementsNum = fn.search([[^\s*]] .. logCommand, "nw")
	cmd([[g/^\s*]] .. logCommand .. [[/d]])

	vim.notify(" Cleared " .. tostring(logsStatementsNum) .. " log statements. ")
	cmd("nohl")
end

--------------------------------------------------------------------------------
-- MOVEMENT
-- performed via `:normal` makes them less glitchy

function M.moveLineDown()
	if lineNo(".") == lineNo("$") then return end
	cmd [[. move +1]]
	if bo.filetype ~= "yaml" then cmd [[normal! ==]] end
end

function M.moveLineUp()
	if lineNo(".") == 1 then return end
	cmd [[. move -2]]
	if bo.filetype ~= "yaml" then cmd [[normal! ==]] end
end

function M.moveCharRight()
	if colNo(".") >= colNo("$") - 1 then return end
	cmd [[:normal! "zx"zp]]
end

function M.moveCharLeft()
	if colNo(".") == 1 then return end
	cmd [[:normal! "zdh"zph]]
end

function M.moveSelectionDown()
	leaveVisualMode()
	cmd [['<,'> move '>+1]]
	cmd [[normal! gv=gv]]
end

function M.moveSelectionUp()
	leaveVisualMode()
	cmd [['<,'> move '<-2]]
	cmd [[normal! gv=gv]]
end

function M.moveSelectionRight()
	cmd [[normal! "zx"zpgvlolo]]
end

function M.moveSelectionLeft()
	cmd [[normal! "zdh"zPgvhoho]]
end

--------------------------------------------------------------------------------

return M
