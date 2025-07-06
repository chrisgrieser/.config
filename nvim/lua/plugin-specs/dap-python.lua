-- INFO also needs to add `debugpy` to `mason`
return {
	"mfussenegger/nvim-dap-python",
	dependencies = "mfussenegger/nvim-dap",
	keys = {
		-- so using `dap` in a python file loads `nvim-dap-python`
		{ "7", function() require("dap").continue() end, ft = "python", desc = " Continue (py)" },
	},
	config = function()
		require("dap-python").setup("debugpy-adapter", {
			console = "internalConsole", -- deactivate auto-opening the console by redirecting to internal console
		})
		-- just use the first configuration, so the selection is skipped
		require("dap").configurations.python = { require("dap").configurations.python[1] }
	end,
}
