-- DOCS https://github.com/stevearc/aerial.nvim#options
--------------------------------------------------------------------------------

return {
	"stevearc/aerial.nvim",
	cmd = { "AerialOpen", "AerialToggle", "AerialNavToggle" },
	init = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("aerial", { clear = true }),
			callback = function(ctx)
				if vim.bo[ctx.buf].buftype == "" and vim.bo[ctx.buf].ft == "markdown" then
					return
				end
				if ctx.match == "markdown" then vim.cmd([[AerialOpen!]]) end
			end,
		})
	end,
	opts = {
		layout = {
			default_direction = "prefer_right",
		},
		close_automatic_events = { "switch_buffer", "unfocus" },
		-- autojump = false,
		-- filter_kind = { }
	},
}
