local M = {}

local cmd = vim.cmd
local qfCount

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
---@nodiscard
function M.counter()
	local totalItems = countCurQuickfix()
	if totalItems == 0 or not qfCount then return "" end
	return (" %s/%s"):format(qfCount, totalItems)
end

--------------------------------------------------------------------------------

-- when user updates quickfixlist, also works with Telescope
function M.setup()
	vim.api.nvim_create_autocmd("QuickFixCmdPost", {
		callback = function() qfCount = nil end,
	})
end

--------------------------------------------------------------------------------
-- KEYMAPS

---delete the quickfixlist
function M.deleteList()
	if qfCount then qfCount = nil end -- de-initialize
	vim.cmd.cexpr("[]")
end

function M.next()
	if quickFixIsEmpty() then return end
	if not qfCount then qfCount = 0 end -- initialize counter

	local wentToNext = pcall(function() cmd("silent cnext") end)
	if wentToNext then
		qfCount = qfCount + 1
	else
		cmd("silent cfirst")
		qfCount = 1
		notify("Wrapped to beginning", "trace")
	end
	openFoldUnderCursor()
end

---goto previous quickfix and wrap around
function M.previous()
	if quickFixIsEmpty() then return end
	if not qfCount then qfCount = countCurQuickfix() end -- initialize counter

	local wentToPrevious = pcall(function() cmd("silent cprevious") end)
	if wentToPrevious then
		qfCount = qfCount - 1
	else
		cmd("silent clast")
		qfCount = countCurQuickfix()
		notify("Wrapped to end", "trace")
	end
	openFoldUnderCursor()
end

--------------------------------------------------------------------------------
return M
