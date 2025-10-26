local M = {}
--------------------------------------------------------------------------------

local config = {
	filetypes = {
		"json",
		"yaml",
	},
	objectTypes = {
		"pair", -- json
		"block_mapping_pair", -- yaml
		"flow_pair", -- yaml
	},
	arrayTypes = {
		"array", -- json
		"block_sequence", -- yaml
	},
	statusline = {
		separator = " ",
		icon = "󰳮",
	},
}

--------------------------------------------------------------------------------

local function getBreadcrumbs()
	local crumbs = {}
	local node = vim.treesitter.get_node()
	local prevNode

	-- loop upwards through the parents of the node
	while node do
		if vim.list_contains(config.objectTypes, node:type()) then
			local keyName = vim.treesitter.get_node_text(node, 0):match("[%w-_]+")
			table.insert(crumbs, 1, keyName)
		elseif vim.list_contains(config.arrayTypes, node:type()) then
			local indexOfChild
			for i = 0, node:named_child_count() do
				local child = assert(node:named_child(i))
				if child:id() == prevNode:id() then
					indexOfChild = i
					break
				end
			end
			assert(indexOfChild, "Could not find index of child")
			table.insert(crumbs, 1, "[" .. indexOfChild .. "]")
		end
		prevNode = node
		node = node:parent()
	end

	return crumbs
end

function M.statusline()
	local text = table.concat(getBreadcrumbs(), config.statusline.separator)
	if text == "" then return "" end
	return vim.trim(config.statusline.icon .. " " .. text)
end

function M.copy()
	local breadcrumbs = getBreadcrumbs()
	if #breadcrumbs == 0 then
		local msg = "No breadcrumbs to copy."
		vim.notify(msg, vim.log.levels.WARN, { icon = config.icon, title = "Breadcrumbs" })
		return
	end

	local text = table.concat(breadcrumbs, "."):gsub("%.%[", "%[")
	-- add leading `.` for `jq` and `yq`
	if vim.list_contains({ "json", "jsonc", "yaml" }, vim.bo.filetype) then text = "." .. text end

	vim.fn.setreg("+", text)
	vim.notify(text, nil, { icon = config.icon, title = "Copied", ft = "text" })
end

--------------------------------------------------------------------------------
return M
