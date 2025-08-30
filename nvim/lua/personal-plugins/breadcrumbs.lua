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
	local prevNode

	-- loop upwards through the parents of the node
	while node do
		if vim.tbl_contains(config.objectTypes, node:type()) then
			local keyName = vim.treesitter.get_node_text(node, 0):match("[%w-_]+")
			table.insert(crumbs, 1, keyName)
		elseif vim.tbl_contains(config.arrayTypes, node:type()) then
			local indexOfChild
			for i = 0, node:named_child_count() do
				local child = assert(node:named_child(i))
				if child:id() == prevNode:id() then
					indexOfChild = i
					break
				end
			end
			local arrayPos = ("[%d]"):format(indexOfChild)
			table.insert(crumbs, 1, arrayPos)
		end
		prevNode = node
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
	-- uses the format that is valid for tools like `jq`
	local text = "." .. table.concat(getBreadcrumbs(), "."):gsub("%.%[", "%[")

	if text == "" then
		local msg = "No breadcrumbs to copy."
		vim.notify(msg, vim.log.levels.WARN, { icon = config.icon, title = "Breadcrumbs" })
	else
		vim.fn.setreg("+", text)
		vim.notify(text, nil, { icon = config.icon, title = "Copied", ft = "text" })
	end
end

--------------------------------------------------------------------------------
return M
