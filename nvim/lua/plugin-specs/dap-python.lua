-- INFO also needs to add `debugpy` to `mason`
return {
	"mfussenegger/nvim-dap-python",
	dependencies = "mfussenegger/nvim-dap",
	keys = {
		-- so it's loaded when used in a python file
		{ "7", function() require("dap").continue() end, ft = "python", desc = " Continue (py)" },
	},
	config = function()
		-- 1. use the debugypy installation by mason
		-- 2. deactivate auto-opening the console by redirecting to internal console
		local debugpyPythonPath = vim.env.MASON .. "/packages/debugpy/venv/bin/python3"
		require("dap-python").setup(debugpyPythonPath, { console = "internalConsole" })
	end,
}
