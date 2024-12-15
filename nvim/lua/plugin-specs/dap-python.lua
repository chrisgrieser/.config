-- INFO also needs to add `debugpy` to `mason`
return {
	"mfussenegger/nvim-dap-python",
	ft = "python",
	config = function()
		-- 1. use the debugypy installation by mason
		-- 2. deactivate auto-opening the console by redirecting to internal console
		local debugpyPythonPath = require("mason-registry").get_package("debugpy"):get_install_path()
			.. "/venv/bin/python3"
		require("dap-python").setup(debugpyPythonPath, { console = "internalConsole" }) ---@diagnostic disable-line: missing-fields
	end,
}
