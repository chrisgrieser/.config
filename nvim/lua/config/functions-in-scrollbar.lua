-- DOCS https://github.com/lewis6991/satellite.nvim/blob/main/HANDLERS.md#handlers
--------------------------------------------------------------------------------

local config = {
	hlgroup = "Function",
	icon = "",
	tsquery = [[(function_declaration) @user.funcs]],
	priority = 1000,
	leftOfScrollbar = false,
}

--------------------------------------------------------------------------------

---@type Satellite.Handler
local handler = {
	name = "functions-in-scrollbar",
	ns = vim.api.nvim_create_namespace("functions-in-scrollbar.satellite"),
	config = {
		enable = true,
		overlap = not config.leftOfScrollbar,
		priority = config.priority,
	},
	enabled = function() return true end,
	update = function(bufnr, _winid)
		local currentFt = vim.bo[bufnr].filetype
		local hasFunction, query = pcall(vim.treesitter.query.parse, currentFt, config.tsquery)
		if not hasFunction then return {} end

		local rootTree = vim.treesitter.get_parser(bufnr):parse()[1]:root()
		local allNodesIter = query:iter_captures(rootTree, bufnr)

		local satelliteMarks = vim.iter(allNodesIter)
			:map(function(_, node, _)
				local row, _, _ = node:start()
				return {
					pos = row,
					highlight = config.hlgroup,
					symbol = config.icon,
				}
			end)
			:totable()

		return satelliteMarks
	end,
}
--------------------------------------------------------------------------------
require("satellite.handlers").register(handler)
