-- DOCS https://github.com/stevearc/aerial.nvim#options
--------------------------------------------------------------------------------

return {
	"stevearc/aerial.nvim",
	cmd = { "AerialOpen", "AerialToggle", "AerialNavToggle" },
	init = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("aerial", { clear = true }),
			callback = function(ctx)
				local bufname = vim.api.nvim_buf_get_name(ctx.buf)
				if vim.startswith(bufname, vim.g.notesDir) then
					vim.schedule(function() vim.cmd("AerialOpen!") end)
				end
			end,
		})
	end,
	opts = {
		layout = {
			default_direction = "prefer_right",
			min_width = vim.o.columns - vim.o.textwidth - 8,
		},
		close_automatic_events = { "switch_buffer", "unfocus" },
		autojump = true,
		-- filter_kind = { }
	},
}
