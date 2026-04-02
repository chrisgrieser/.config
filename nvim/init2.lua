require("config.lazy")

--------------------------------------------------------------------------------


local lightColor = "dawnfox"
local darkColor = "tokyonight"

vim.g.neovide_theme = "auto"
local prevBg
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = function()
		-- prevent recursion, since some colorschemes also set background
		if vim.v.option_new == prevBg then return end
		prevBg = vim.v.option_new

		vim.cmd.highlight("clear") -- so next theme isn't affected by previous one
		local newColor = vim.v.option_new == "light" and lightColor or darkColor
		vim.schedule(function() vim.cmd.colorscheme(newColor) end)
	end,
})
