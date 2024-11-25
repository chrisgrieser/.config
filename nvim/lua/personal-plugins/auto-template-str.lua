local M = {}
--------------------------------------------------------------------------------

---@param msg string
local function warn(msg)
	vim.notify(msg, vim.log.levels.WARN, { title = "Auto-template-string", icon = "󰅳" })
end

--------------------------------------------------------------------------------

local function luaFunc()
	local node = vim.treesitter.get_node()
	if not node then return end
	local strNode
	if node:type() == "string" then
		strNode = node
	elseif node:type():find("string_content") then
		strNode = node:parent()
	elseif node:type() == "escape_sequence" then
		strNode = node:parent():parent()
	end
	if not strNode then return end

	local nodeText = vim.treesitter.get_node_text(strNode, 0)
	local row, nodeStartCol, _, nodeEndCol = strNode:range()

	-- insert `%s` at cursor
	local cursorCol = vim.api.nvim_win_get_cursor(0)[2]
	local posInNode = cursorCol - nodeStartCol
	nodeText = nodeText:sub(1, posInNode) .. "%s" .. nodeText:sub(posInNode + 1)

	local newText = ("(%s):format()"):format(nodeText)
	vim.api.nvim_buf_set_text(0, row, nodeStartCol, row, nodeEndCol, { newText })
	local moveToRight = 12 -- length of `%s` & `():format()`
	vim.api.nvim_win_set_cursor(0, { row + 1, nodeEndCol + moveToRight })
end

local function pyFunc()
	-- WIP
	local node = vim.treesitter.get_node()
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
	if not strNode then return end
	local nodeText = vim.treesitter.get_node_text(strNode, 0)
	nodeText = "f" .. nodeText

	local startRow, startCol, endRow, endCol = strNode:range()
	vim.api.nvim_buf_set_text(0, startRow, startCol, endRow, endCol, vim.split(nodeText, "\n"))
end

local function jsFunc()
	local node = vim.treesitter.get_node()
	if not node then return end
	if node:type() == "string_fragment" or node:type() == "escape_sequence" then
		node = node:parent()
	end
	if not node or not vim.endswith(node:type(), "string") then return end
	local strNode = node

	local nodeText = vim.treesitter.get_node_text(strNode, 0)
	local row, nodeStartCol, _, nodeEndCol = strNode:range()
	local cursorCol = vim.api.nvim_win_get_cursor(0)[2]
	local posInNode = cursorCol - nodeStartCol

	-- insert `${}` at cursor
	nodeText = nodeText:sub(1, posInNode) .. "${}" .. nodeText:sub(posInNode + 1)
	nodeText = "`" .. nodeText:sub(2, -2) .. "`" -- switch to backticks
	vim.api.nvim_buf_set_text(0, row, nodeStartCol, row, nodeEndCol, { nodeText })
	vim.api.nvim_win_set_cursor(0, { row + 1, cursorCol + 2 }) -- move into braces
end

--------------------------------------------------------------------------------

function M.insertTemplateStr()
	if vim.fn.mode() ~= "i" then
		warn("Only works in insert mode.")
		return
	end

	local availableTransformers = {
		lua = luaFunc,
		python = pyFunc,
		javascript = jsFunc,
		typescript = jsFunc,
	}
	local transformer = availableTransformers[vim.bo.filetype]

	if transformer then
		transformer()
	else
		warn("No transformer configured for " .. vim.bo.ft)
	end
end

--------------------------------------------------------------------------------
return M
