-- DOCS https://github.com/lewis6991/satellite.nvim/blob/main/HANDLERS.md#handlers
local util = require("satellite.util")
--------------------------------------------------------------------------------

local HIGHLIGHT = "ErrorMsg"

--- @type Satellite.Handler
local handler = {
	name = "chainsaw",
	config = {
		enable = true,
		overlap = true,
		priority = 100,
	},
	ns = vim.api.nvim_create_namespace("chainsaw.satellite-integration"),
	enabled = function() return true end,
	update = function(_, winid)
		local lnum = 10
		local pos, _ = util.row_to_barpos(winid, lnum)

		---@type Satellite.Mark[]
		local marks = {
			{ pos = pos, highlight = HIGHLIGHT, symbol = "A" },
		}
		return marks
	end,
}

require("satellite.handlers").register(handler)
