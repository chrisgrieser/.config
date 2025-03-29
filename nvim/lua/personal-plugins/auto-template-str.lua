local M = {}
--------------------------------------------------------------------------------

---@param msg string
local function warn(msg)
	vim.notify(msg, vim.log.levels.WARN, { title = "Auto-template-string", icon = "󰅳" })
end

---@param strNode? TSNode
---@param insertAtCursor string text to insert at cursor location
---@param textTransformer fun(nodeText: string): string
---@param cursorMove "nodeEnd"|nil where to move the cursor before applying `cursorOffset`
---@param cursorOffset number number of columns to move to the right
local function updateNode(strNode, insertAtCursor, textTransformer, cursorMove, cursorOffset)
	if not strNode then return end
	local nodeText = vim.treesitter.get_node_text(strNode, 0)
	if nodeText:find("[\n\r]") then
		warn("Multiline strings not supported yet.")
		return
	end
	local nodeRow, nodeStartCol, _, nodeEndCol = strNode:range()
	local _, cursorCol = unpack(vim.api.nvim_win_get_cursor(0))

	-- 1. `insertAtCursor`
	local posInNode = cursorCol - nodeStartCol
	nodeText = nodeText:sub(1, posInNode) .. insertAtCursor .. nodeText:sub(posInNode + 1)

	-- 2. `textTransformer`
	nodeText = textTransformer(nodeText)
	vim.api.nvim_buf_set_text(0, nodeRow, nodeStartCol, nodeRow, nodeEndCol, { nodeText })

	-- 3. `cursorMove`
	if cursorMove == "nodeEnd" then cursorCol = nodeEndCol end

	-- 4. `cursorOffset`
	vim.api.nvim_win_set_cursor(0, { nodeRow + 1, cursorCol + cursorOffset })
end

--------------------------------------------------------------------------------

---@param node TSNode
local function luaStr(node)
	local strNode
	if node:type() == "string" then
		strNode = node
	elseif node:type():find("string_content") then
		strNode = node:parent()
	elseif node:type() == "escape_sequence" then
		strNode = node:parent():parent()
	end
	local transformer = function(nodeText) return "(" .. nodeText .. "):format()" end
	updateNode(strNode, "%s", transformer, "nodeEnd", 12)
end

---@param node TSNode
local function pyStr(node)
	local strNode
	if node:type() == "string" then
		strNode = node
	elseif node:type():find("^string_") then
		strNode = node:parent()
	elseif node:type() == "escape_sequence" then
		strNode = node:parent():parent()
	end
	local transformer = function(nodeText) return "f" .. nodeText end
	updateNode(strNode, "{}", transformer, nil, 2)
end

---@param node TSNode
local function jsStr(node)
	local strNode
	if node:type() == "string" or node:type() == "template_string" then
		strNode = node
	elseif node:type() == "string_fragment" or node:type() == "escape_sequence" then
		strNode = node:parent()
	end
	local transformer = function(nodeText) return "`" .. nodeText:sub(2, -2) .. "`" end
	updateNode(strNode, "${}", transformer, nil, 2)
end

--------------------------------------------------------------------------------

function M.insertTemplateStr()
	if vim.fn.mode() ~= "i" then
		warn("Only works in insert mode.")
		return
	end

	local availableFiletypes = {
		lua = luaStr,
		python = pyStr,
		javascript = jsStr,
		typescript = jsStr,
	}
	local updateFunc = availableFiletypes[vim.bo.ft]
	if not updateFunc then
		warn("Not configured for " .. vim.bo.ft)
		return
	end

	local nodeAtCursor = vim.treesitter.get_node()
	if nodeAtCursor then updateFunc(nodeAtCursor) end
end

--------------------------------------------------------------------------------
return M
