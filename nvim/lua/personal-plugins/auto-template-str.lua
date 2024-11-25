local M = {}
--------------------------------------------------------------------------------

---@param msg string
local function warn(msg)
	vim.notify(msg, vim.log.levels.WARN, { title = "Auto-template-string", icon = "󰅳" })
end

---@param strNode TSNode
---@param insertAtCursor string text to insert
---@param cursorMove number|"end" number of columns to move to the right, or moving to end of nodeCursor
---@param textTransformer fun(nodeText: string): string applied after inserting text at cursor
local function updateNode(strNode, insertAtCursor, cursorMove, textTransformer)
	local nodeText = vim.treesitter.get_node_text(strNode, 0)
	if nodeText:find("[\n\r]") then
		warn("Multiline strings not supported yet.")
		return
	end
	local nodeRow, nodeStartCol, _, nodeEndCol = strNode:range()
	local _, cursorCol = unpack(vim.api.nvim_win_get_cursor(0))
	local posInNode = cursorCol - nodeStartCol

	nodeText = nodeText:sub(1, posInNode) .. insertAtCursor .. nodeText:sub(posInNode + 1)
	nodeText = textTransformer(nodeText)
	vim.api.nvim_buf_set_text(0, nodeRow, nodeStartCol, nodeRow, nodeEndCol, { nodeText })

	vim.api.nvim_win_set_cursor(0, { nodeRow + 1, cursorCol + cursorMove })
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

	updateNode(strNode, "%s", "end", function(nodeText) return "(" .. nodeText .. "):format()" end)
end

local function pyFunc()
	local node = vim.treesitter.get_node()
	if not node then return end
	local strNode
	if node:type() == "string" then
		strNode = node
	elseif node:type():find("^string_") then
		strNode = node:parent()
	elseif node:type() == "escape_sequence" then
		strNode = node:parent():parent()
	end
	if not strNode then return end

	updateNode(strNode, "{}", 2, function(nodeText) return "f" .. nodeText end)
end

local function jsFunc()
	local node = vim.treesitter.get_node()
	if not node then return end
	if node:type() == "string_fragment" or node:type() == "escape_sequence" then
		node = node:parent()
	end
	if not node or not vim.endswith(node:type(), "string") then return end
	local strNode = node

	updateNode(strNode, "${}", 2, function(nodeText) return "`" .. nodeText:sub(2, -2) .. "`" end)
end

--------------------------------------------------------------------------------

function M.insertTemplateStr()
	if vim.fn.mode() ~= "i" then
		warn("Only works in insert mode.")
		return
	end

	local availableFiletypes = {
		lua = luaFunc,
		python = pyFunc,
		javascript = jsFunc,
		typescript = jsFunc,
	}
	local updateFunc = availableFiletypes[vim.bo.filetype]

	if updateFunc then
		updateFunc()
	else
		warn("No transformer configured for " .. vim.bo.ft)
	end
end

--------------------------------------------------------------------------------
return M
