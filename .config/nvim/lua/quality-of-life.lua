---@diagnostic disable: param-type-mismatch, undefined-field
local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local fn = vim.fn
local getline = vim.fn.getline
local lineNo = vim.fn.line
local append = vim.fn.append
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local error = vim.log.levels.ERROR
local warn = vim.log.levels.WARN
local function wordUnderCursor() return vim.fn.expand("<cword>") end

local function leaveVisualMode()
	-- https://github.com/neovim/neovim/issues/17735#issuecomment-1068525617
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

--------------------------------------------------------------------------------

---Helper Function performing common file operation tasks
---@param operation string rename|duplicate|new
local function fileOp(operation)
	local oldName = fn.expand("%:t")
	local oldExt = fn.expand("%:e")

	local promptStr
	if operation == "duplicate" then promptStr = "Duplicate File as: "
	elseif operation == "rename" then promptStr = "Rename File to: "
	elseif operation == "new" then promptStr = "New File: "
	end

	vim.ui.input({prompt = promptStr}, function(newName)
		if not (newName) then return end -- cancel
		if newName:find("^%s*$") or newName:find("/") or newName:find(":") or newName:find("\\") then
			vim.notify(" Invalid Filename.", error)
			return
		end
		local extProvided = newName:find("%.")
		if not (extProvided) then
			newName = newName .. "." .. oldExt
		end
		if operation == "duplicate" then
			cmd("saveas " .. newName)
			cmd("edit " .. newName)
			vim.notify(" Duplicated '" .. oldName .. "' as '" .. newName .. "'.")
		elseif operation == "rename" then
			os.rename(oldName, newName)
			cmd("edit " .. newName)
			cmd("bdelete #")
			vim.notify(" Renamed '" .. oldName .. "' to '" .. newName .. "'.")
		elseif operation == "new" then
			cmd("edit " .. newName)
			cmd("write " .. newName)
		end
	end)
end

---Rename Current File
-- - if no extension is provided, the current extensions will be kept
-- - uses vim.ui.input and vim.notify, so plugins like dressing.nvim or
--   notify.nvim are automatically supported
function M.renameFile() fileOp("rename") end

---Duplicate Current File
-- - if no extension is provided, the current extensions will be kept
-- - uses vim.ui.input and vim.notify, so plugins like dressing.nvim or
--   notify.nvim are automatically supported
function M.duplicateFile() fileOp("duplicate") end

---Create New File
-- - if no extension is provided, the extensions of the current file will be used
-- - uses vim.ui.input and vim.notify, so plugins like dressing.nvim or
--   notify.nvim are automatically supported
function M.createNewFile() fileOp("new") end

---run `chmod +x` on the current file
function M.chmodx()
	local currentFile = fn.expand("%:p")
	os.execute("chmod +x " .. "'" .. currentFile .. "'")
	vim.notify(" Execution permission granted.")
end

---Helper for copying file information
---@param operation string filename|filepath
---@param reg? string register to copy to
local function copyOp (operation, reg)
	if not (reg) then reg = "+" end
	local toCopy
	if operation == "filename" then
		toCopy = fn.expand("%:t")
	elseif operation == "filepath" then
		toCopy = fn.expand("%:p")
	end
	fn.setreg(reg, toCopy)
	vim.notify(" COPIED\n "..toCopy)
end

---Copy full path of current file
---@param opts? table
function M.copyFilepath(opts)
	if not (opts) then opts = {reg = "+"} end
	copyOp("filepath", opts.reg)
end

???LINES MISSING
???LINES MISSING
???LINES MISSING
	cmd [[:normal! xhP]]
end

--------------------------------------------------------------------------------

return M
