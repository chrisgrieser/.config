-- DOCS https://github.com/lewis6991/satellite.nvim/blob/main/HANDLERS.md#handlers
--------------------------------------------------------------------------------

local config = {
	hlgroup = "Comment",
	icon = "󰫳", -- ·
	tsquery = {
		lua = { "function_declaration", "function_definition" },
		javascript = { "function_declaration", "arrow_function" },
	},
	priority = 10, -- below all builtin satellite-handlers, as they are more important
	leftOfScrollbar = false,
	excludeOneLineFuncs = true,
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

		local queryStr = vim.iter(tsquery)
			:map(function(nodeType) return "(" .. nodeType .. ")" end)
			:join("")
		queryStr = ("[%s] @user.funcs"):format(queryStr)
		local hasFunction, query = pcall(vim.treesitter.query.parse, currentFt, queryStr)
		if not hasFunction then return {} end

		local rootTree = vim.treesitter.get_parser(bufnr):parse()[1]:root()
		local allNodesIter = query:iter_captures(rootTree, bufnr)

		local satelliteMarks = vim.iter(allNodesIter):fold({}, function(acc, _, node, _)
			local startRow = node:start()
			local endRow = node:end_()
			if config.excludeOneLineFuncs and (startRow == endRow) then return acc end
			local scrollbarPos, _ = require("satellite.util").row_to_barpos(winid, startRow)

			---@type Satellite.Mark
			local mark = {
				pos = scrollbarPos,
				highlight = config.hlgroup,
				symbol = config.icon,
			}
			return vim.list_extend(acc, { mark })
		end)

		return satelliteMarks
	end,
}
--------------------------------------------------------------------------------
require("satellite.handlers").register(handler)
