-- DOCS https://github.com/stevearc/aerial.nvim#options
--------------------------------------------------------------------------------

return {
	"stevearc/aerial.nvim",
	cmd = "AerialToggle",
	event = "VeryLazy",
	keys = {
		{ "<D-0>", vim.cmd.AerialToggle, desc = " Aerial Toggle" },
	},
	opts = {
		layout = {
			default_direction = "prefer_right",
			min_width = vim.o.columns - vim.o.textwidth - 8,
		},
		close_automatic_events = { "switch_buffer", "unfocus" },
		autojump = false,
		on_attach = function(bufnr)
			vim.keymap.set("n", "<D-w>", function()
				vim.cmd.AerialClose()
				vim.cmd.bdelete()
			end, { buffer = bufnr, desc = "Close Aerial with buffer" })
		end,
		open_automatic = function(bufnr)
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			return vim.startswith(bufname, vim.g.notesDir)
		end,
	},
}
