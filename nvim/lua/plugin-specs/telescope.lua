-- Telescope is only needed as dependency for `tinygit` until I find time to
-- migrate to `snacks.picker` there
--------------------------------------------------------------------------------

-- FIX / PENDING https://github.com/nvim-telescope/telescope.nvim/issues/3436
local initialWinborder = vim.o.winborder
vim.api.nvim_create_autocmd("User", {
	pattern = "TelescopeFindPre",
	callback = function()
		vim.opt.winborder = "none"
		vim.api.nvim_create_autocmd("WinLeave", {
			once = true,
			callback = function() vim.opt.winborder = initialWinborder end,
		})
	end,
})

--------------------------------------------------------------------------------

return {
	"nvim-telescope/telescope.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	cmd = "Telescope",
	opts = {
		defaults = {
			path_display = { "tail" },
			selection_caret = " ",
			prompt_prefix = " ",
			borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
			default_mappings = {
				i = {
					["<Esc>"] = "close", -- = disables normal mode for Telescope
					["<Tab>"] = "move_selection_worse",
					["<S-Tab>"] = "move_selection_better",
					["<D-Up>"] = "move_to_top",
					["<CR>"] = "select_default",

					["<PageDown>"] = "preview_scrolling_down",
					["<PageUp>"] = "preview_scrolling_up",
				},
			},
			layout_strategy = "horizontal",
			sorting_strategy = "ascending", -- so layout is consistent with `prompt_position = "top"`
			layout_config = {
				horizontal = {
					prompt_position = "top",
					height = { 0.6, min = 13 },
					width = 0.99,
					preview_cutoff = 70,
					preview_width = { 0.55, min = 30 },
				},
			},
		},
	},
}
