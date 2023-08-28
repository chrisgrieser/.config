return {
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
		event = "VenvSelect",
		opts = {
			name = { "venv", ".venv" },
			auto_refresh = true,
		},
	},
	{ -- fix indentation issues in python https://www.reddit.com/r/neovim/comments/wyx4e4/q_auto_indentation_for_python_files/
		"Vimjas/vim-python-pep8-indent",
		ft = "python",
	},
}
