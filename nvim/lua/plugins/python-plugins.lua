
return {
	{ -- docstrings / annotation comments
		"danymat/neogen",
		opts = true,
		keys = {
			{
				"qf",
				function() require("neogen").generate { type = "func" } end,
				desc = " Function Annotation",
			},
			{
				"qF",
				function() require("neogen").generate { type = "file" } end,
				desc = " File Annotation",
			},
			{
				"qt",
				function() require("neogen").generate { type = "type" } end,
				desc = " Type Annotation",
			},
		},
	},
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
}
