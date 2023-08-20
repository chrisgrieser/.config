---@return string
local function currentLine() return vim.api.nvim_get_current_line() end

--------------------------------------------------------------------------------

-- auto-convert string to template string when typing `${..}` inside string
local function templateStr()
	local correctedLine = currentLine():gsub("[\"'](.*${.-}.*)[\"']", "`%1`")
	vim.api.nvim_set_current_line(correctedLine)
end

-- auto-convert string to f-string when typing `{..}` inside string
-- TODO better using treesitter: https://www.reddit.com/r/neovim/comments/tge2ty/python_toggle_fstring_using_treesitter/
local function fStr()
	-- first capture group is non-f character to not re-apply to f-string itself
	local correctedLine = currentLine():gsub([[([^f])(["'].*{.-}.*["'])]], "%1f%2")
	vim.api.nvim_set_current_line(correctedLine)
end

-- auto-apply str:format() to string when typing `%s` inside string
local function luaFormatStr()
	local curLine = currentLine()
	if curLine:find(":format") then return end -- avoid re-applying to already formatted string
	local correctedLine = curLine:gsub([[(["'].*%%s.*["'])]], "(%1):format()")
	vim.api.nvim_set_current_line(correctedLine)
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "javascript", "typescript", "lua" },
	callback = function(ctx)
		local ft = ctx.match
		local func
		if ft == "lua" then func = luaFormatStr end
		if ft == "python" then func = fStr end
		if ft == "javascript" or ft == "typescript" then func = templateStr end
		vim.api.nvim_create_autocmd("InsertLeave", {
			buffer = 0,
			callback = func,
		})
	end,
})
