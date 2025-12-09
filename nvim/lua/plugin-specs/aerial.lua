-- DOCS https://github.com/stevearc/aerial.nvim#options
--------------------------------------------------------------------------------

local wasClosedManually

return {
	"stevearc/aerial.nvim",
	cmd = "AerialToggle",
	event = "VeryLazy",
	keys = {
		{
			"<D-0>",
			function()
				wasClosedManually = require("aerial").is_open()
				require("aerial").toggle { focus = false }
			end,
			desc = "󱘎 Aerial Toggle",
		},
	},
	opts = {
		layout = {
			default_direction = "prefer_right",
			min_width = vim.o.columns - vim.o.textwidth - 4,
			win_opts = { winhighlight = "Normal:ColorColumn" },
		},
		open_automatic = function(bufnr)
			local narrowWin = vim.api.nvim_win_get_width(0) < vim.o.textwidth
			if narrowWin then return false end
			if vim.bo[bufnr].ft == "yaml" then return false end
			if vim.bo[bufnr].ft == "markdown" then return true end -- always open in markdown

			local symbols = require("aerial").num_symbols(bufnr)
			local smallFile = vim.api.nvim_buf_line_count(bufnr) < 120
			local manySymbols = symbols > 8
			if symbols == 0 then manySymbols = true end -- FIX closing aerial resulting in 0 for buffer

			return (not smallFile) and manySymbols and not wasClosedManually
		end,
		close_automatic_events = { "switch_buffer", "unfocus", "unsupported" },

		post_parse_symbol = function(_bufnr, item, _ctx) return item.name ~= "callback" end,

		on_attach = function(bufnr)
			vim.keymap.set("n", "<C-j>", vim.cmd.AerialNext, { buffer = bufnr })
			vim.keymap.set("n", "<C-k>", vim.cmd.AerialPrev, { buffer = bufnr })

			vim.api.nvim_create_autocmd("WinClosed", {
				desc = "User: Close aerial when win is closed",
				buffer = bufnr,
				once = true,
				callback = function()
					wasClosedManually = false
					require("aerial").close()
				end,
			})
		end,
	},
}
