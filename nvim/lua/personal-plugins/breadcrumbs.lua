local M = {}
--------------------------------------------------------------------------------

local config = {
	nodes = {
		json = {
			object = "pair",
			array = "array",
		},
		yaml = {
			object = ".*_pair", -- `flow_pair` or `block_mapping_pair`
			array = "block_sequence$", -- not: `block_sequence_item`
		},
		lua = {
			object = "field",
			array = "table_constructor",
		},
	},
	oneBasedIndexing = { "lua", "r", "julia" },
	icons = {
		main = "󰳮",
		statuslineSeparator = " ",
	},
}

--------------------------------------------------------------------------------

local function getBreadcrumbs()
	local node = vim.treesitter.get_node()
	local ftNodes = config.nodes[vim.bo.ft]
	if not ftNodes or not node then return {} end

	-- loop upwards through the parents of the node
	local crumbs = {}
	local prevNode
	repeat
		local isObject = node:type():match(ftNodes.object)
		local isArray = node:type():match(ftNodes.array)

		-- exception, since lua objects & arrays are both tables
		if vim.bo.ft == "lua" then
			if #node:field("name") == 0 then isObject = false end
			if prevNode and #prevNode:field("name") > 0 then isArray = false end
		end

		if isObject then
			local keyName = vim.treesitter.get_node_text(node, 0):match("[%w-_]+")
			table.insert(crumbs, 1, keyName)
		elseif isArray then
			local indexOfChild = vim.list_contains(config.oneBasedIndexing, vim.bo.ft) and 1 or 0
			local prevId = prevNode and prevNode:id() or -1
			for _, child in ipairs(node:named_children()) do
				if child:id() == prevId then
					table.insert(crumbs, 1, "[" .. indexOfChild .. "]")
					break
				end
				indexOfChild = indexOfChild + 1
			end
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

	local text = "." .. table.concat(breadcrumbs, "."):gsub("%.%[", "%[")

	vim.fn.setreg("+", text)
	vim.notify(text, nil, { icon = config.icons.main, title = "Copied", ft = "text" })
end

--------------------------------------------------------------------------------
return M
