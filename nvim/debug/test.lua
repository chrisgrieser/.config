local function getAllReturnStatements(bufnr)
	bufnr = bufnr or 0
	local query = vim.treesitter.query.parse("lua", [[ ((return_statement) @keyword.return) ]])
	local rootTree = vim.treesitter.get_parser(bufnr):parse()[1]:root()
	local nodes = query:iter_captures(rootTree, bufnr)
	local rows = vim
		.iter(nodes) -- iterator over nodes
		:map(function(_, node, _) return node:start() + 1 end)
		:totable()
	return rows
end

local total = getAllReturnStatements()
vim.notify(vim.inspect(total), nil, { title = "🪚 total", ft = "lua" })
