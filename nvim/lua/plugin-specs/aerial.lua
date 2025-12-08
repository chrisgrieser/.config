-- DOCS https://github.com/stevearc/aerial.nvim#options
--------------------------------------------------------------------------------

return {
	"stevearc/aerial.nvim",
	cmd = "AerialToggle",
	event = "VeryLazy",
	keys = {
		{ "<D-0>", "<cmd>AerialToggle!<CR>", desc = " Aerial Toggle" },
	},
	opts = {
		layout = {
			default_direction = "prefer_right",
			min_width = vim.o.columns - vim.o.textwidth - 8,
			win_opts = { winhighlight = "Normal:ColorColumn" },
		},
		close_automatic_events = { "switch_buffer", "unfocus", "unsupported" },
		open_automatic = function(bufnr)
			-- if vim.startswith(vim.api.nvim_buf_get_name(bufnr), vim.g.notesDir) then return true end
			if vim.bo[bufnr].filetype == "markdown" then return true end
			return vim.api.nvim_buf_line_count(bufnr) > 80
				and require("aerial").num_symbols(bufnr) > 10
				and not require("aerial").was_closed() -- was manually closed
		end,
		on_attach = function(bufnr)
			vim.keymap.set("n", "<D-j>", vim.cmd.AerialNext, { buffer = bufnr })
			vim.keymap.set("n", "<D-k>", vim.cmd.AerialPrev, { buffer = bufnr })

			-- FIX close `aerial` when buffer is closed
			vim.keymap.set("n", "<D-w>", "<cmd>AerialClose<CR><cmd>bdelete<CR>", { buffer = bufnr })
		end,
	},
}
