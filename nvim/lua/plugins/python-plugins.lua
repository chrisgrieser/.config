local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-telescope/telescope.nvim",
			"mfussenegger/nvim-dap-python",
		},
		cmd = { "VenvSelect", "VenvSelectCached" },
		keys = {
			{ "<localleader>v", "<cmd>VenvSelect<CR>", ft = "python", desc = "󱥒 VenvSelect" },
		},
		config = function()
			require("venv-selector").setup {
				name = { ".venv" },
				auto_refresh = true,
				notify_user_on_activate = false,
				dap_enabled = true, -- requires: nvim-dap-python, debugpy, nvim-dap
				parents = 0, -- no need to search upwards, since projects.nvim sets pwd to the correct root already

				-- FIX change of pyright capabilities: https://github.com/linux-cultist/venv-selector.nvim/issues/58#issuecomment-1707835221
				changed_venv_hooks = {
					function(_, venv_python)
						require("venv-selector.hooks").execute_for_client("pyright", function(pyright)
							pyright.config.settings = vim.tbl_deep_extend(
								"force",
								pyright.config.settings,
								{ python = { pythonPath = venv_python } }
							)
							pyright.notify("workspace/didChangeConfiguration", { settings = nil })
						end)
					end,
				},
			}
			u.addToLuaLine("tabline", "lualine_a", function()
				if vim.bo.ft ~= "python" then return "" end
				local venv = require("venv-selector").get_active_venv()
				if venv == "" then return "" end
				venv = vim.fs.basename(venv)
				venv = venv:find("^%.?venv$") and "" or " " .. venv -- only add venv-name, if non-default
				return "󱥒" .. venv
			end)
		end,
		init = function()
			-- auto-select venv on entering python buffer -- https://github.com/linux-cultist/venv-selector.nvim#-automate
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "python",
				callback = function()
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
