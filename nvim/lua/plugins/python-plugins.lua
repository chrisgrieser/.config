local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- debugger preconfig for python
		"mfussenegger/nvim-dap-python",
		ft = "python",
		config = function()
			-- 1. use the debugypy installation by mason
			-- 2. deactivate the annoying auto-opening the console by redirecting
			-- to the internal console
			local debugpyPythonPath = require("mason-registry")
				.get_package("debugpy")
				:get_install_path() .. "/venv/bin/python3"
			require("dap-python").setup(debugpyPythonPath, { console = "internalConsole" })

			-- Set virtual environment correctly
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "python",
				callback = function()
					local venv_python = u.determineVenv()
					if not venv_python then return end
					require("dap-python").resolve_python = function() return venv_python end
				end,
			})
		end,
	},
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
}
