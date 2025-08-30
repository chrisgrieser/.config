local M = {}
--------------------------------------------------------------------------------

local config = {
	objectTypes = {
		"pair", -- json
		"block_mapping_pair", -- yaml
		"flow_pair", -- yaml
	},
	arrayTypes = {
		"array", -- json
		"block_sequence", -- yaml
	},
	separator = " ",
	icon = "󰳮",
}

--------------------------------------------------------------------------------

local function getBreadcrumbs()
	local crumbs = {}
	local node = vim.treesitter.get_node()
	local prev
	while node do
		if vim.tbl_contains(config.objectTypes, node:type()) then
			local keyName = vim.treesitter.get_node_text(node, 0):match("[%w-_]+")
			table.insert(crumbs, 1, keyName)
		elseif vim.tbl_contains(config.arrayTypes, node:type()) then
			local index = 0
			for child, _ in node:iter_children() do
				if child:id() == prev:id() then break end
				index = index + 1
			end
			local arrayPos = ("[%d]"):format(index)
			table.insert(crumbs, 1, arrayPos)
		end
		prev = node
		node = node:parent()
	end
	return crumbs
end

function M.statusline()
	local text = table.concat(getBreadcrumbs(), config.separator)
	if text == "" then return "" end
	return vim.trim(config.icon .. " " .. text)
end

function M.copy()
	local text = table.concat(getBreadcrumbs(), ".")
	local notifyOpts = { icon = config.icon, title = "Breadcrumbs" }
	if text == "" then
		vim.notify("No breadcrumbs to copy.", vim.log.levels.WARN, notifyOpts)
		return
	end
	vim.fn.setreg("+", text)
	vim.notify("Copied\n" .. text, nil, notifyOpts)
end

--------------------------------------------------------------------------------
return M
