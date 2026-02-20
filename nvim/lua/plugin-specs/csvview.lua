-- DOCS https://github.com/hat0uma/csvview.nvim/blob/main/GUIDE.md
--------------------------------------------------------------------------------

return {
	"hat0uma/csvview.nvim",
	ft = "csv",
	keys = {
		{ "<leader>cc", "<cmd>CsvViewToggle<CR>", desc = " CSV view toggle", ft = "csv" },
		{ "<leader>ci", "<cmd>CsvViewInfo<CR>", desc = " CSV view info", ft = "csv" },
		{
			"<leader>cl",
			function()
				vim.ui.input({ prompt = "Comment lines: " }, function(input)
					local lines = assert(tonumber(input), "Comment lines must be a number.")
					local csvview = require("csvview")
					local bufnr = vim.api.nvim_get_current_buf()
					if csvview.is_enabled(bufnr) then csvview.disable(bufnr) end
					csvview.enable(bufnr, { parser = { comment_lines = lines } })
				end)
			end,
			desc = " Set number of leading comment lines",
			ft = "csv",
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: auto-enable csv view",
			pattern = "csv",
			callback = vim.schedule_wrap(function(ctx)
				if require("csvview").is_enabled(ctx.buf) then return end
				require("csvview").enable(ctx.buf)
			end),
		})

		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: Highlights for csview.nvim",
			callback = function() vim.api.nvim_set_hl(0, "CsvViewHeaderLine", { link = "Bold" }) end,
		})
	end,
	opts = {
		parser = {
			delimiter = {
				ft = { csv = ";" },
			},
			comment_lines = 0, -- first x lines treated as comments
			comments = { "#" },
		},
		view = {
			spacing = 1,
			display_mode = "border",
		},
		keymaps = {
			-- Text objects for selecting fields
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },

			-- Excel-like navigation
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
		},
	},
}
