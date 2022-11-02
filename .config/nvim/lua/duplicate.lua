---@diagnostic disable: param-type-mismatch, undefined-field
local getline = vim.fn.getline
local append = vim.fn.append
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor

local dup = {}

function dup.setup(options) ---@diagnostic disable-line: unused-local
	-- placeholder for potential future options
end

function dup.duplicateLine()
	local line = getline(".") 
	append(".", line)
	local lineNum = getCursor(0)[1] + 1 -- line down
	local colNum = getCursor(0)[2]
	setCursor(0, {lineNum, colNum})
end

function dup.duplicateVisual()
	local prevReg = vim.fn.getreg("z")
	cmd[[silent! "zy`]"zp]]
	vim.fn.setreg("z", prevReg)
end

function dup.smartDuplicateLine()
	local line = getline(".")
	if line:find("top") then line = line:gsub("top", "bottom")
	elseif line:find("bottom") then line = line:gsub("bottom", "top")
	elseif line:find("right") then line = line:gsub("right", "left")
	elseif line:find("left") then line = line:gsub("left", "right")
	elseif line:find("height") and not(line:find("line-height")) then
		line = line:gsub("height", "width")
	elseif line:find("width") and not(line:find("border-width")) and not(line:find("outline-width")) then
		line = line:gsub("width", "height")
	end
	append(".", line)

	-- cursor movement
	local lineNum = getCursor(0)[1] + 1 -- line down
	local colNum = getCursor(0)[2]
	local _, valuePos = line:find(": ?")
	if valuePos then -- if line was changed, move cursor to value of the property
		colNum = valuePos 
	end 
	api.nvim_win_set_cursor(0, {lineNum, colNum})
end

return dup
