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
				vim.g.wasClosedManually = require("aerial").is_open()
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
			local ft = vim.bo[bufnr].filetype
			if ft == "markdown" then return true end
			if ft == "yaml" then return false end

			return vim.api.nvim_buf_line_count(bufnr) > 80
				and require("aerial").num_symbols(bufnr) > 8
		end,
		close_automatic_events = { "switch_buffer", "unfocus", "unsupported" },

		post_parse_symbol = function(_bufnr, item, _ctx) return item.name ~= "callback" end,

		on_attach = function(bufnr)
			vim.keymap.set("n", "<D-j>", "<cmd>AerialNext<CR>", { buffer = bufnr })
			vim.keymap.set("n", "<D-k>", "<cmd>AerialPrev<CR>", { buffer = bufnr })

			vim.api.nvim_create_autocmd("WinClosed", {
				desc = "User: Close aerial when win is closed",
				buffer = bufnr,
				once = true,
				callback = function()
					vim.g.wasClosedManually = false
					require("aerial").close()
				end,
			})
		end,
	},
}
