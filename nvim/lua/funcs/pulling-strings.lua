---set the current line to `line`, if it is different
---@param line string
---@return boolean whether line has been changed
local function setIfChanges(line)
	if line == vim.api.nvim_get_current_line() then return false end
	vim.api.nvim_set_current_line(line)
	return true
end

--------------------------------------------------------------------------------

-- auto-convert string to template string when typing `${..}` inside string
local function templateStr()
	local curLine = vim.api.nvim_get_current_line()
	if curLine:find("`.*`") then return end -- already template string
	local correctedLine = curLine:gsub("[\"'](.*${.-}.*)[\"']", "`%1`")
	setIfChanges(correctedLine)
end

-- auto-convert string to f-string when typing `{..}` inside string
-- TODO better using treesitter: https://www.reddit.com/r/neovim/comments/tge2ty/python_toggle_fstring_using_treesitter/
local function pythonFStr()
	-- first capture group is non-f character to not re-apply to f-string itself
	local correctedLine = vim.api.nvim_get_current_line():gsub([[([^f])(["'].*{.-}.*["'])]], "%1f%2")
	setIfChanges(correctedLine)
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "javascript", "typescript" },
	callback = function(ctx)
		local ft = ctx.match
		local func
		if ft == "python" then func = pythonFStr end
		if ft == "javascript" or ft == "typescript" then func = templateStr end
		vim.api.nvim_create_autocmd("InsertLeave", {
			buffer = 0,
			callback = func,
		})
	end,
})
