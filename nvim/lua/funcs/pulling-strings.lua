local ts = vim.treesitter
--------------------------------------------------------------------------------

-- auto-convert string to template string when typing `${..}` inside string
local function templateStr()
	local node = ts.get_node()
	if not node then return end
	local strNode
	local type
	if node:type() == "string" then
		strNode = node
		type = "string"
	elseif node:type() == "string_fragment" or node:type() == "escape_sequence" then
		strNode = node:parent()
		type = "string"
	else
		return
	end
	local text = ts.get_node_text(strNode, 0)

	local isTemplateStr = text:find("${.-}")
	local hasBraces = text:find("${.-}")
	if (isTemplateStr and hasBraces) or (not isTemplateStr and not hasBraces) then
		return
	elseif not isTemplateStr and hasBraces then
		text = "f" .. text
	elseif isTemplateStr and not hasBraces then
		text = text:sub(2)
	end

	local startRow, startCol, endRow, endCol = strNode:range()
	local lines = vim.split(text, "\n")
	vim.api.nvim_buf_set_text(0, startRow, startCol, endRow, endCol, lines)
end

-- auto-convert string to f-string when typing `{..}` inside string
-- TODO better using treesitter: https://www.reddit.com/r/neovim/comments/tge2ty/python_toggle_fstring_using_treesitter/
local function pythonFStr()
	local node = ts.get_node()
	if not node then return end
	local strNode
	if node:type() == "string" then
		strNode = node
	elseif node:type():find("^string_") then
		strNode = node:parent()
	elseif node:type() == "escape_sequence" then
		strNode = node:parent():parent()
	else
		return
	end
	local text = ts.get_node_text(strNode, 0)

	local isFString = text:find("^f")
	local hasBraces = text:find("{.-}")
	if (isFString and hasBraces) or (not isFString and not hasBraces) then
		return
	elseif not isFString and hasBraces then
		text = "f" .. text
	elseif isFString and not hasBraces then
		text = text:sub(2)
	end

	local startRow, startCol, endRow, endCol = strNode:range()
	local lines = vim.split(text, "\n")
	vim.api.nvim_buf_set_text(0, startRow, startCol, endRow, endCol, lines)
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
