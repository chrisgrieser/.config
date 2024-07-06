
-- DOCS https://github.com/nvim-treesitter/nvim-treesitter#adding-queries

local query = vim.treesitter.query.parse("comment", "(uri) @string.special.url")

local parser = vim.treesitter.get_parser(0)
vim.notify("👾 parser: " .. vim.inspect(parser))




vim.treesitter.get_parser(0):for_each_tree(function(tstree, tree)
	local root = tstree:root()
	local iter = query:iter_captures(root, 0)

	for _, node, _ in iter do
		local text = vim.treesitter.get_node_text(node, 0)
		vim.notify("👾 text: " .. vim.inspect(text))
	end
end)
