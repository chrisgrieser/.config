
local function getAllReturnStatemetns()
	local bufnr = 0
	local query = vim.treesitter.query.parse("lua", [[
		((return_statement) @keyword.return)
	]])

	-- local rootTree = vim.treesitter.get_node():tree():root()
	local rootTree = vim.treesitter.get_parser(bufnr):parse()[1]:root()
	local rows = vim.iter(query:iter_captures(rootTree, bufnr)):map(function (_, node, _)
		local row = node:start()
		return row
	end)
	return rows
end

local total = getAllReturnStatemetns()
vim.notify(vim.inspect(total), nil, { title = "🪚 total", ft = "lua" })

