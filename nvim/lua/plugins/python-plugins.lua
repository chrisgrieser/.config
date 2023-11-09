return {
	{ -- import python modules action
		"stevanmilic/nvim-lspimport",
		enabled = false, -- TODO requires nvim 0.10
		keys = {
			{
				"<leader>i",
				function() require("lspimport").import() end,
				ft = "python",
				desc = "󰒕 Import",
			},
		},
	},
	{ -- fix python indentation issues
		"Vimjas/vim-python-pep8-indent",
		ft = "python",
	},
}
