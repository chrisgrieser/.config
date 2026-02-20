return {
	"hat0uma/csvview.nvim",
	ft = "csv",
	keys = {
		{ "<leader><leader>", "<cmd>CsvViewToggle<CR>", desc = " CSV view", ft = "csv" },
	},
	opts = {
		parser = {
			delimiter = {
				ft = { csv = ";" },
			},
		},
		keymaps = {
			-- Text objects for selecting fields
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },

			-- Excel-like navigation:
			-- Use <Tab> and <S-Tab> to move horizontally between fields.
			-- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
			-- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
			jump_next_row = { "<Nop>", mode = { "n", "v" } },
			jump_prev_row = { "<Nop>", mode = { "n", "v" } },
		},
	},
}
