---@return string
local function currentLine() return vim.api.nvim_get_current_line() end

---set the current line to `line`, if it is different
---@param line string
---@return boolean whether line has been changed
local function setIfChanges(line)
	if line == currentLine() then return false end
	vim.api.nvim_set_current_line(line)
	return true
end

--------------------------------------------------------------------------------

-- auto-convert string to template string when typing `${..}` inside string
local function templateStr()
	local correctedLine = currentLine():gsub("[\"'](.*${.-}.*)[\"']", "`%1`")
	setIfChanges(correctedLine)
end

-- auto-convert string to f-string when typing `{..}` inside string
-- TODO better using treesitter: https://www.reddit.com/r/neovim/comments/tge2ty/python_toggle_fstring_using_treesitter/
local function pythonFStr()
	-- first capture group is non-f character to not re-apply to f-string itself
	local correctedLine = currentLine():gsub([[([^f])(["'].*{.-}.*["'])]], "%1f%2")
	setIfChanges(correctedLine)
end

-- auto-apply str:format() to string when typing `%s` inside string
local function luaFormatStr()
	if currentLine():find(":format") then return end -- avoid re-applying to already formatted string
	local correctedLine = currentLine():gsub([[(["'].*%%s.*["'])]], "(%1):format()")
	local changed = setIfChanges(correctedLine)

	if not changed then return end
	-- enter argument for string.format
	vim.cmd.normal { "f:f)", bang = true }
	vim.cmd.startinsert()
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "javascript", "typescript", "lua" },
	callback = function(ctx)
		local ft = ctx.match
		local func
		if ft == "lua" then func = luaFormatStr end
		if ft == "python" then func = pythonFStr end
		if ft == "javascript" or ft == "typescript" then func = templateStr end
		vim.api.nvim_create_autocmd("InsertLeave", {
			buffer = 0,
			callback = func,
		})
	end,
})
