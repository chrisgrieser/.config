local M = {}
--------------------------------------------------------------------------------

function M.getBreadcrumbs()
	local validTypes = { "pair" }
	local crumbs = {}
	local node = vim.treesitter.get_node()
	while node do
		if node:named() and vim.tbl_contains(validTypes, node:type()) then
			local nodeName = vim.treesitter.get_node_text(node, 0):match("[%w-_]+")
			if nodeName then table.insert(crumbs, nodeName) end
		end
		node = node:parent()
	end
	return table.concat(crumbs, ">")
end

--------------------------------------------------------------------------------
return M
