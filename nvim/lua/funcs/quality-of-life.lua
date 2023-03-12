local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local b = vim.b
local opt = vim.opt
local fn = vim.fn
local cmd = vim.cmd
local lineNo = vim.fn.line
local colNo = vim.fn.col
local expand = vim.fn.expand

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

--------------------------------------------------------------------------------

-- HORIZONTAL DIVIDER
function M.commentHr()
	---@diagnostic disable: param-type-mismatch
	local linechar = "─"
	local wasOnBlank = fn.getline(".") == ""
	local indent = fn.indent(".")
	local textwidth = bo.textwidth
	local comStr = bo.commentstring
	local ft = bo.filetype
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

	fn.append(".", linesToAppend)

	-- shorten if it was on blank line, since fn.indent() does not return indent
	-- line would have if it has content
	if wasOnBlank then
		normal("j==")
		local hrIndent = fn.indent(".")
		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = fn.getline(".") ---@diagnostic disable-next-line: assign-type-mismatch, undefined-field
		hrLine = hrLine:gsub(linechar, "", hrIndent)
		fn.setline(".", hrLine)
	else
		normal("jj==")
	end
	---@diagnostic enable: param-type-mismatch
end

---switches words under the cursor from `true` to `false` and similar cases
function M.wordSwitch()
	local iskeywBefore = opt.iskeyword:get()
	opt.iskeyword:remove { "_", "-", "." }

	local words = {
		{ "true", "false" },
		{ "warn", "error" },
		{ "on", "off" },
		{ "yes", "no" },
		{ "disable", "enable" },
		{ "disabled", "enabled" },
		{ "show", "hide" },
		{ "right", "left" },
		{ "red", "blue" },
		{ "top", "bottom" },
		{ "min", "max" },
		{ "always", "never" },
		{ "width", "height" },
		{ "relative", "absolute" },
		{ "low", "high" },
		{ "dark", "light" },
		{ "before", "after" },
		{ "and", "or" },
		{ "next", "previous" },
		{ "read", "write" },
	}
	local ft = bo.filetype
	local ftWords -- 3rd item false if 2nd item shouldn't also switch to first
	if ft == "lua" then
		ftWords = {
			{ "if", "elseif", false },
			{ "elseif", "else", false },
			{ "else", "if", false },
			{ "function", "local function", false },
			{ "pairs", "ipairs" },
			{ "find", "match" },
			{ "Notify", "print", false }, -- hammerspoon specific
		}
	elseif ft == "python" then
		ftWords = {
			{ "True", "False" },
		}
	elseif ft == "bash" or ft == "zsh" or ft == "sh" then
		ftWords = {
			{ "if", "elif", false },
			{ "elif", "else", false },
			{ "else", "if", false },
			{ "echo", "print" },
			{ "exit", "return" },
		}
	elseif ft == "javascript" or ft == "typescript" then
		ftWords = {
			{ "if", "} else if", false },
			{ "else", "else if", false },
			{ "var", "const", false },
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
		fn.setreg("z", newWord)
		normal([[viw"zP]])
	else
		vim.notify("Word under cursor cannot be switched.", vim.log.levels.WARN)
	end

	opt.iskeyword = iskeywBefore
end

--------------------------------------------------------------------------------
-- UNDO

-- Save Open time
vim.api.nvim_create_augroup("undoTimeMarker", {})
vim.api.nvim_create_autocmd("BufReadPost", {
	group = "undoTimeMarker",
	callback = function() b.timeOpened = os.time() end,
})

---select between common undopoints: present, last open, 1h ago, and 15min ago
function M.undoDuration()
	local now = os.time() -- saved in epoch secs
	local secsPassed = now - b.timeOpened
	local minsPassed = math.floor(secsPassed / 60)
	local resetLabel = "last open (~" .. tostring(minsPassed) .. "m ago)"
	local undoOptionsPresented = { " present", resetLabel, "15m", "1h", "24h" }

	vim.ui.select(undoOptionsPresented, { prompt = "Undo…" }, function(choice)
		if not choice then return end
		if choice:find("ago") then
			cmd.earlier(secsPassed .. "s")
		elseif choice:find("present") then
			cmd.later(tostring(opt.undolevels:get())) -- redo as much as there are undolevels
		else
			cmd.earlier(choice)
		end
	end)
end

--------------------------------------------------------------------------------

---enables overscrolling for that action when close to the last line, depending
---on 'scrolloff' option. Alternative Approach: https://www.reddit.com/r/neovim/comments/10rhoxs/how_to_make_scrolloff_option_scroll_past_end_of/
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
	local opts = { buffer = true }

	local wrapOn = vim.opt_local.wrap:get()
	if wrapOn then
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = opt.colorcolumn:get()
		vim.keymap.del({ "n", "x" }, "H", opts)
		vim.keymap.del({ "n", "x" }, "L", opts)
		vim.keymap.del({ "n", "x" }, "J", opts)
		vim.keymap.del({ "n", "x" }, "K", opts)
		vim.keymap.del({ "n", "x" }, "k", opts)
		vim.keymap.del({ "n", "x" }, "j", opts)
	else
		vim.opt_local.wrap = true
		vim.opt_local.colorcolumn = ""
		vim.keymap.set({ "n", "x" }, "H", "g^", opts)
		vim.keymap.set({ "n", "x" }, "L", "g$", opts)
		vim.keymap.set({ "n", "x" }, "J", function() M.overscroll("6gj") end, opts)
		vim.keymap.set({ "n", "x" }, "K", "6gk", opts)
		vim.keymap.set({ "n", "x" }, "k", "gk", opts)
		vim.keymap.set({ "n", "x" }, "j", function() M.overscroll("gj") end, opts)
	end
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
