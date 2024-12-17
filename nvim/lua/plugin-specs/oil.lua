return {
	"stevearc/oil.nvim",
	dependencies = "echasnovski/mini.icons",

	keys = {
		{ "<leader>fo", "<cmd>Oil<cr>", desc = "󰁴 Oil" },
	},

	---@module "oil"
	---@type oil.SetupOpts
	opts = {
		delete_to_trash = false,
		skip_confirm_for_simple_edits = false,
		prompt_save_on_select_new_entry = true,
		keymaps = {
			["?"] = { "actions.show_help", mode = "n" },
			["<CR>"] = "actions.select",
			["q"] = { "actions.close", mode = "n", nowait = true },
			["<BS>"] = { "actions.parent", mode = "n" },
			["<Tab>"] = { "actions.open_cwd", mode = "n" },
			["gs"] = { "actions.change_sort", mode = "n" },
			["g."] = { "actions.toggle_hidden", mode = "n" },
		},
		float = {
			-- Padding around the floating window
			max_width = 0.9,
			max_height = 0.9,
			border = vim.g.borderStyle,
			win_options = { statuscolumn = " " }, -- adds padding
			preview_split = "auto", -- direction: "auto", "left", "right", "above", "below"

			-- optionally override the oil buffers window title with custom function: fun(winid: integer): string
			get_win_title = nil,
		},
	},
}
