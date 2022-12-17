local normal = vim.cmd.normal
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local fn = vim.fn
local M = {}
local lookForwardLines = 5
--------------------------------------------------------------------------------

---md links textobj
---@param inner boolean inner or outer link
function M.linkTextobj(inner)
	---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
	local lineContent = fn.getline(".") ---@type string
	local curRow, curCol = unpack(getCursor(0))
	local linkStart, linkEnd, barelink, hasLink
	local i = 0

	normal { "F[", bang = true } -- go to beginning of link so it can be found when standing on it
	local mdLinkPattern = "(%b[])%b()"
	while not hasLink do
		i = i + 1
		---@diagnostic disable-next-line: assign-type-mismatch
		lineContent = fn.getline(curRow + i) ---@type string
		hasLink = lineContent:find(mdLinkPattern)
		if i > lookForwardLines then
			setCursor(0, { curRow, curCol }) -- re
			return
		end
	end
	curRow = curRow + i
	if inner then
		linkStart, _, barelink = lineContent:find(mdLinkPattern, curCol)
		linkEnd = linkStart + #barelink - 3
	else
		linkStart, linkEnd = lineContent:find(mdLinkPattern, curCol)
		linkStart = linkStart - 1
		linkEnd = linkEnd - 1
	end

	setCursor(0, { curRow, linkStart })
	if fn.mode():find("v") then
		normal { "o", bang = true }
	else
		normal { "v", bang = true }
	end
	setCursor(0, { curRow, linkEnd })
end

--------------------------------------------------------------------------------
return M
