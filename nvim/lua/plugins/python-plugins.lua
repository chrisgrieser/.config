return {
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = { "chrisgrieser/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
		cmd = { "VenvSelect", "VenvSelectCached" },
		config = function()
			require("venv-selector").setup {
				-- enable_debug_output = true,
				name = { ".venv" },
				auto_refresh = true,
				notify_user_on_activate = false,
				dap_enabled = false, -- requires: nvim-dap-python, debugpy, nvim-dap
				parents = 0, -- no need to search upwards, since projects.nvim sets pwd to the correct root already
			}
			require("config.utils").addToLuaLine("tabline", "lualine_a", function ()
				if vim.bo.ft ~= "python" then return "" end
				local venv = require("venv-selector").get_active_venv()
				if venv == "" then return "" end
				venv = vim.fs.basename(venv)
				venv = venv:find("^%.?venv$") and "" or " " .. venv -- only add venv-name, if non-default
				return "󱥒" .. venv
			end)
		end,
		-- auto-select venv on entering python buffer -- https://github.com/linux-cultist/venv-selector.nvim#-automate
		init = function()
			vim.api.nvim_create_autocmd("BufReadPost", {
				callback = function()
					if vim.bo.ft ~= "python" then return end
					vim.defer_fn(function()
						local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
						if venv ~= "" then require("venv-selector").retrieve_from_cache() end
					end, 250)
				end,
			})
		end,
	},
	{ -- fix indentation issues in python https://www.reddit.com/r/neovim/comments/wyx4e4/q_auto_indentation_for_python_files/
		"Vimjas/vim-python-pep8-indent",
		ft = "python",
	},
}
