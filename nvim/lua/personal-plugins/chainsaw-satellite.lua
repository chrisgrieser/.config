-- DOCS https://github.com/lewis6991/satellite.nvim/blob/main/HANDLERS.md#handlers
--------------------------------------------------------------------------------

local config = {
	enabled = false,
	hlgroup = "DiagnosticSignInfo",
	icon = "ﰉ",
	leftOfScrollbar = false,
	priority = 60, -- compared to other handlers from `satellite` (diagnostics are 50)
}

--------------------------------------------------------------------------------

---@param bufnr number
---@return number[] rows
local function getRowsWithMarker(bufnr)
	local ns = vim.api.nvim_create_namespace("chainsaw.markers")
	local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
	local rows = vim
		.iter(extmarks)
		:filter(function(extm) return not extm[4].invalid end) -- exclude deleted extmarks
		:map(function(extm) return extm[2] + 1 end)
		:totable()
	return rows
end

--- @type Satellite.Handler
local handler = {
	name = "chainsaw",
	config = {
		enable = true,
		overlap = not config.leftOfScrollbar,
		priority = config.priority,
	},
	ns = vim.api.nvim_create_namespace("chainsaw.satellite-integration"),
	enabled = function() return package.loaded["chainsaw"] end,
	update = function(bufnr, winid)
		local rows = getRowsWithMarker(bufnr)

		---@type Satellite.Mark[]
		local satelliteMarks = vim.tbl_map(function(row)
			local pos, _ = require("satellite.util").row_to_barpos(winid, row)
			return {
				pos = pos,
				highlight = config.hlgroup,
				symbol = config.icon,
			}
		end, rows)

		return satelliteMarks
	end,
}

require("satellite.handlers").register(handler)
