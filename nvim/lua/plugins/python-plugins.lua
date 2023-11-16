--# selene: allow(mixed_table) -- lazy.nvim uses them
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
		end,
	},
	-- { -- import python modules action
	-- 	"stevanmilic/nvim-lspimport",
	-- 	keys = {
	-- 		{
	-- 			"<leader>i",
	-- 			function() require("lspimport").import() end,
	-- 			ft = "python",
	-- 			desc = "󰒕 Import",
	-- 		},
	-- 	},
	-- },
}
