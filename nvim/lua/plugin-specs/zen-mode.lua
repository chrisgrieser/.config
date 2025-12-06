return {
	"folke/zen-mode.nvim",
	opts = {
		window = {
			width = vim.o.textwidth, -- width of the Zen window
			options = {
				signcolumn = "no",
				colorcolumn = "",
				wrap = true,
				formatlistpat = vim.o.formatlistpat .. [[\|^\s*>\s\+]], -- also indent blockquotes via `breakindentopt`
			},
		},
		on_open = function(win)
			local buf = vim.api.nvim_win_get_buf(win)
			vim.keymap.set("n", "I", "g^i", { buffer = buf })
			vim.keymap.set("n", "A", "g$a", { buffer = buf })
			vim.defer_fn(function() vim.wo[win].showbreak = "" end, 1)

			vim.api.nvim_create_autocmd("BufLeave", {
				buffer = buf,
				callback = function()
					require("zen-mode").close()
				end,
			})
		end,
	},
}
