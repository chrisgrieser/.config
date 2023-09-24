local M = {}

local g = vim.g
local cmd = vim.cmd

local function normal(theCmd) vim.cmd.normal { theCmd, bang = true } end

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	local pluginName = "Quickfix"
	vim.notify(msg, vim.log.levels[level:upper()], { title = pluginName })
end

--------------------------------------------------------------------------------

---checks whether quickfixlist is empty and notifies if it is
---@nodiscard
---@return boolean
local function quickFixIsEmpty()
	local isEmpty = #vim.fn.getqflist() == 0
	if isEmpty then notify("Quickfix list is empty.", "warn") end
	return isEmpty
end

---@return integer
local function countCurQuickfix() return #vim.fn.getqflist() end

local function openFoldUnderCursor() cmd.normal { "zv", bang = true } end

--------------------------------------------------------------------------------

-- STATUSLINE COMPONENT
function M.counter()
	local totalItems = countCurQuickfix()
	if totalItems == 0 then return "" end
	local out = " "
	if g.qfCount then out = out .. tostring(g.qfCount) .. "/" end
	out = out .. tostring(totalItems)
	return out
end

--------------------------------------------------------------------------------

-- when user updates quickfixlist, also works with Telescope
function M.setup()
	vim.api.nvim_create_autocmd("QuickFixCmdPost", {
		callback = function() g.qfCount = nil end,
	})
end

--------------------------------------------------------------------------------
-- KEYMAPS

---delete the quickfixlist
function M.deleteList()
	if g.qfCount then g.qfCount = nil end -- de-initialize
	vim.cmd.cexpr("[]")
end

---goto next quickfix and wrap around
function M.next()
	if quickFixIsEmpty() then return end
	if not g.qfCount then g.qfCount = 0 end -- initialize counter

	local wentToNext = pcall(function() cmd("silent cnext") end)
	if wentToNext then
		g.qfCount = g.qfCount + 1
		openFoldUnderCursor()
	else
		cmd("silent cfirst")
		g.qfCount = 1
		notify("Wrapped to beginning", "trace")
	end
	normal("zv") -- open folder under cursor
end

---goto previous quickfix and wrap around
function M.previous()
	if quickFixIsEmpty() then return end
	if not g.qfCount then g.qfCount = countCurQuickfix() end -- initialize counter

	local wentToPrevious = pcall(function() cmd("silent cprevious") end)
	if wentToPrevious then
		g.qfCount = g.qfCount - 1
		openFoldUnderCursor()
	else
		cmd("silent clast")
		g.qfCount = countCurQuickfix()
		notify("Wrapped to end", "trace")
	end
	normal("zv") -- open folder under cursor
end

--------------------------------------------------------------------------------
return M
