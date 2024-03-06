local M = {}

---@param cmd string
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

local g = vim.g
local fn = vim.fn

--------------------------------------------------------------------------------

---check whether a global mark is set
---@param mark string
---@return boolean
local function globalMarkIsSet(mark)
	local globalMarks = fn.getmarklist()
	local markObj = vim.tbl_filter(function(item) return item.mark:sub(2, 2) == mark end, globalMarks)
	return markObj > 0
end

local marks = { "A", "B" }
function M.gotoMark()
	if not g.markOneGo then g.markOneGo = true end

	local markToGo
	if g.markOneGo and globalMarkIsSet(marks[1]) then
		markToGo = marks[1]
	elseif not (g.markOneGo) and globalMarkIsSet(marks[2]) then
		markToGo = marks[2]
	elseif globalMarkIsSet(marks[1]) then
		markToGo = marks[1]
	elseif globalMarkIsSet(marks[2]) then
		markToGo = marks[2]
	else
		vim.notify("No mark set yet.", vim.log.levels.WARN)
		return
	end
	normal("`" .. markToGo)
	g.markOneGo = not g.markOneGo
	vim.notify("Jumping to " .. markToGo .. ". ")
end

function M.setMark()
	if not g.markOne then g.markOne = true end
	local markToSet = g.markOne and marks[1] or marks[2]
	normal("m" .. markToSet)
	vim.notify("Mark " .. markToSet .. " set. ")
	g.markOne = not g.markOne
end

--------------------------------------------------------------------------------
return M
