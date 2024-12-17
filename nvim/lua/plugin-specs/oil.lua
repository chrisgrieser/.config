return {
	"stevearc/oil.nvim",
	dependencies = "echasnovski/mini.icons",

	keys = {
		{ "<leader>fo", "<cmd>Oil --float<CR>", desc = "󰁴 Oil" },
	},

	---@module "oil"
	---@type oil.SetupOpts
	opts = {
		delete_to_trash = true,
		skip_confirm_for_simple_edits = false,
		use_default_keymaps = false,
		keymaps = {
			["?"] = { "actions.show_help", mode = "n" },
			["<CR>"] = "actions.select",
			["q"] = { "actions.close", mode = "n", nowait = true },
			["<Tab>"] = { "actions.parent", mode = "n" },
			["<D-r>"] = { "actions.refresh" },
			["<D-s>"] = {
				function()
					require("oil").save()
					require("oil").close()
				end,
				desc = "Save & close",
			},
		},
		columns = { "icon" }, -- mtime,size
		win_options = { statuscolumn = " " }, -- adds paddings
		float = {
			border = vim.g.borderStyle,
			override = function(conf)
				local height = 0.8
				local width = 0.6
				conf.row = math.floor((1 - height) / 2 * vim.o.lines)
				conf.col = math.floor((1 - width) / 2 * vim.o.columns)
				conf.height = math.floor(vim.o.lines * height)
				conf.width = math.floor(vim.o.columns * width)
				return conf
			end,
		},
	},
}
