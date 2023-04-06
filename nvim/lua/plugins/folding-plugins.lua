
local function numOfFoldedLines()
	local lines = vim.v.foldend - vim.v.foldstart + 1
	return tostring(lines) .. " 󰘖"
end

--------------------------------------------------------------------------------

return {
	{
		"jghauser/fold-cycle.nvim",
		lazy = true, -- loaded by keymap
		opts = true,
	},
	{
		"anuvyklack/pretty-fold.nvim",
		event = "UIEnter",
		opts = {
			process_comment_signs = false,
			keep_indentation = true,
			fill_char = " ",
			sections = {
				left = { "content", "   ", numOfFoldedLines },
				right = { },
			},
		},
	},
}
