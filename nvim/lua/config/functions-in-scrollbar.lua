-- DOCS https://github.com/lewis6991/satellite.nvim/blob/main/HANDLERS.md#handlers
--------------------------------------------------------------------------------

local config = {
	hlgroup = "Comment",
	icon = "·",
	tsquery = {
		lua = {
			"function_declaration",
			"function_",
		}
			[=[
			[ (function_declaration) (function_definition) ] @user.funcs
		]=],
		javascript = [=[
			[ (function_declaration) (arrow_function) ] @user.funcs
		]=],
	},
	priority = 10, -- diagnostics use 20
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
	update = function(bufnr, winid)
		local currentFt = vim.bo[bufnr].filetype
		local tsquery = config.tsquery[currentFt]
		if not tsquery then return {} end
		local hasFunction, query = pcall(vim.treesitter.query.parse, currentFt, tsquery)
		if not hasFunction then return {} end

		local rootTree = vim.treesitter.get_parser(bufnr):parse()[1]:root()
		local allNodesIter = query:iter_captures(rootTree, bufnr)

		local satelliteMarks = vim.iter(allNodesIter)
			:map(function(_, node, _)
				local row, _, _ = node:start()
				local scrollbarPos, _ = require("satellite.util").row_to_barpos(winid, row)
				return {
					pos = scrollbarPos,
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
