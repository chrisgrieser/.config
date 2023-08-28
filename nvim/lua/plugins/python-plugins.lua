return {
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
		cmd = { "VenvSelect", "VenvSelectCached" },
		opts = {
			name = { "venv", ".venv" },
			auto_refresh = true,
		},
		-- auto-select venv on entering python buffer -- https://github.com/linux-cultist/venv-selector.nvim#-automate
		init = function()
			vim.api.nvim_create_autocmd("BufReadPost", {
				callback = function()
					if vim.bo.ft ~= "python" then return end
					vim.defer_fn(function()
						local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
						if venv ~= "" then require("venv-selector").retrieve_from_cache() end
					end, 200)
				end,
			})
		end,
	},
	{ -- fix indentation issues in python https://www.reddit.com/r/neovim/comments/wyx4e4/q_auto_indentation_for_python_files/
		"Vimjas/vim-python-pep8-indent",
		ft = "python",
	},
}
