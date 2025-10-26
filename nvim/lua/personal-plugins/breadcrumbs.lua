local M = {}
--------------------------------------------------------------------------------

local config = {
	nodes = {
		json = {
			object = "pair",
			array = "array",
		},
		yaml = {
			object = ".*_pair",
			array = "block_sequence",
		},
		lua = {
			object = "field",
			array = "field",
		},
	},
	icons = {
		main = "󰳮",
		statuslineSeparator = " ",
	},
}

--------------------------------------------------------------------------------

local function getBreadcrumbs()
	local node = vim.treesitter.get_node()
	local prevNode
	local ftNodes = config.nodes[vim.bo.ft]
	if not ftNodes or not node then return {} end

	-- loop upwards through the parents of the node
	local crumbs = {}
	repeat
		local isObject = node:type():match(ftNodes.object)
		local isArray = node:type():match(ftNodes.array)

		if isObject then
			local keyName = vim.treesitter.get_node_text(node, 0):match("[%w-_]+")
			table.insert(crumbs, 1, keyName)
		elseif isArray then
			local indexOfChild = 0
			for _, child in ipairs(node:named_children()) do
				if child:id() == prevNode:id() then break end
				indexOfChild = indexOfChild + 1
			end
			table.insert(crumbs, 1, "[" .. indexOfChild .. "]")
		end

		prevNode = node
		node = node:parent()
	until node == nil

	return crumbs
end

function M.statusline()
	local text = table.concat(getBreadcrumbs(), config.icons.statuslineSeparator)
	if text == "" then return "" end
	return vim.trim(config.icons.main .. " " .. text)
end

function M.copy()
	local breadcrumbs = getBreadcrumbs()
	if #breadcrumbs == 0 then
		local msg = "No breadcrumbs to copy."
		vim.notify(msg, vim.log.levels.WARN, { icon = config.icons.main, title = "Breadcrumbs" })
		return
	end

	local text = table.concat(breadcrumbs, "."):gsub("%.%[", "%[")
	-- add leading `.` for `jq` and `yq`
	if vim.list_contains({ "json", "jsonc", "yaml" }, vim.bo.filetype) then text = "." .. text end

	vim.fn.setreg("+", text)
	vim.notify(text, nil, { icon = config.icons.main, title = "Copied", ft = "text" })
end

--------------------------------------------------------------------------------
return M
