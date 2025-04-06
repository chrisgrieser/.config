---@param key "f"| "F"| "t"| "T"
local function cleverF(key)
	-- Eyeliner only adds highlights, nothing else
	require("eyeliner").highlight { forward = true }

	-- Replicating `f` functionality:
	-- Note: this doesn't work with the dot command

	-- Get a character from the user
	local char = vim.fn.getcharstr()
	local lnum = vim.api.nvim_win_get_cursor(0)[1]
	vim.fn.search(char, "", lnum)
end

return {
	"jinh0/eyeliner.nvim",
	keys = { "f", "F", "t", "T" },
	opts = {
		highlight_on_key = true,
		dim = true,
		max_length = 500,
		disabled_buftypes = {},
	},
}
