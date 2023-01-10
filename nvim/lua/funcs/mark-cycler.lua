local M = {}

local g = vim.g
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end
--------------------------------------------------------------------------------

local marks = { "A", "B" } -- the marks to use

--------------------------------------------------------------------------------

function M.clearMarks()
	augroup("markFix", {})
	autocmd("BufReadPost", {
		group = "markFix",
		callback = function()
			-- HACK workaround for https://www.reddit.com/r/neovim/comments/qliuid/the_overly_persistent_marks_problem/
			for _, mark in pairs(marks) do
				vim.cmd.delmarks(mark)
			end
		end,
	})
end

---check whether a global mark is set
---@param mark string
---@return boolean
local function globalMarkIsSet(mark)
	local globalMarks = vim.fn.getmarklist()
	local markObj = vim.tbl_filter(function(item) return item.mark:sub(2, 2) == mark end, globalMarks)
	return #markObj > 0
end

function M.gotoMark()
	if g.markOneGo == nil then g.markOneGo = true end

	-- selene: allow(if_same_then_else) --- more readable this way actually
	if g.markOneGo and globalMarkIsSet(marks[1]) then
		markToGo = marks[1]
	elseif not g.markOneGo and globalMarkIsSet(marks[2]) then
		markToGo = marks[2]
	elseif globalMarkIsSet(marks[1]) then
		markToGo = marks[1]
	elseif globalMarkIsSet(marks[2]) then
		markToGo = marks[2]
	else
		vim.notify("No mark set yet.", logWarn)
		return
	end
	normal("`" .. markToGo)
	g.markOneGo = not g.markOneGo
	vim.notify("Jumping to  " .. markToGo .. ". ")
end

function M.setMark()
	if g.markOne == nil then g.markOne = true end
	local markToSet = g.markOne and marks[1] or marks[2]
	normal("m" .. markToSet)
	vim.notify("Mark " .. markToSet .. " set. ")
	g.markOne = not g.markOne
end

--------------------------------------------------------------------------------

return M
