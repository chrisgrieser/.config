local ts = vim.treesitter

---@param node object
---@param replacementText string
local function replaceNodeText(node, replacementText)
	local startRow, startCol, endRow, endCol = node:range()
	local lines = vim.split(replacementText, "\n")
	vim.api.nvim_buf_set_text(0, startRow, startCol, endRow, endCol, lines)
end

--------------------------------------------------------------------------------

-- auto-convert string to template string and back
local function templateStr()
	local node = ts.get_node()
	if not node then return end
	local strNode
	local isTemplateStr
	if node:type() == "string" then
		strNode = node
		isTemplateStr = false
	elseif node:type() == "string_fragment" or node:type() == "escape_sequence" then
		strNode = node:parent()
		isTemplateStr = false
	elseif node:type() == "template_string" then
		strNode = node
		isTemplateStr = true
	else
		return
	end
	local text = ts.get_node_text(strNode, 0)

	local hasBraces = text:find("${.-}")
	if (isTemplateStr and hasBraces) or (not isTemplateStr and not hasBraces) then
		return
	elseif not isTemplateStr and hasBraces then
		text = "`" .. text:sub(2, -2) .. "`"
	elseif isTemplateStr and not hasBraces then
		text = '"' .. text:sub(2, -2) .. '"'
	end

	replaceNodeText(strNode, text)
end

-- auto-convert string to f-string and back
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

	replaceNodeText(strNode, text)
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
