local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local fn = vim.fn
local cmd = vim.cmd
local lineNo = vim.fn.line
local colNo = vim.fn.col

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

--------------------------------------------------------------------------------
-- UNDO

-- Save Open time
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function() vim.b.timeOpened = os.time() end,
})

---select between common undopoints: present, last open, 1h ago, and 15min ago
function M.undoDuration()
	local now = os.time() -- saved in epoch secs
	local secsPassed = now - vim.b.timeOpened
	local minsPassed = math.floor(secsPassed / 60)
	local resetLabel = "last open (~" .. tostring(minsPassed) .. "m ago)"
	local undoOptionsPresented = { " present", resetLabel, "15m", "1h", "24h" }

	vim.ui.select(undoOptionsPresented, { prompt = "Undo…" }, function(choice)
		if not choice then return end
		if choice:find("ago") then
			cmd.earlier(secsPassed .. "s")
		elseif choice:find("present") then
			cmd.later(tostring(vim.opt.undolevels:get())) -- redo as much as there are undolevels
		else
			cmd.earlier(choice)
		end
	end)
end

--------------------------------------------------------------------------------

---toggle wrap, colorcolumn, and hjkl visual/logical maps in one go
function M.toggleWrap()
	local opts = { buffer = true }
	local wrapOn = vim.opt_local.wrap:get()
	if wrapOn then
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = vim.opt.colorcolumn:get()
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
		vim.keymap.set({ "n", "x" }, "J", "6gj", opts)
		vim.keymap.set({ "n", "x" }, "K", "6gk", opts)
		vim.keymap.set({ "n", "x" }, "j", "gj", opts)
		vim.keymap.set({ "n", "x" }, "k", "gk", opts)
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
