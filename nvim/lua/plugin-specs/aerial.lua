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
			min_width = vim.o.columns - vim.o.textwidth - 4,
			win_opts = { winhighlight = "Normal:ColorColumn" },
		},

		open_automatic = function(bufnr)
			local ft = vim.bo[bufnr].filetype
			if ft == "markdown" then return true end
			if ft == "yaml" then return false end
			-- only open files with at least x symbols, and if aerial wasn't manually closed
			return vim.api.nvim_buf_line_count(bufnr) > 80
				and require("aerial").num_symbols(bufnr) > 8
				and not require("aerial").was_closed() -- was not manually closed
		end,
		close_automatic_events = { "switch_buffer", "unfocus", "unsupported" },

		post_parse_symbol = function(_bufnr, item, _ctx) return item.name ~= "callback" end,

		on_attach = function(bufnr)
			vim.keymap.set("n", "<D-j>", "<cmd>AerialNext<CR>", { buffer = bufnr })
			vim.keymap.set("n", "<D-k>", "<cmd>AerialPrev<CR>", { buffer = bufnr })

			-- FIX close `aerial` when buffer is closed
			vim.keymap.set("n", "<D-w>", "<cmd>AerialClose<CR><cmd>bdelete<CR>", { buffer = bufnr })
		end,
	},
}
