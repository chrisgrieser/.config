-- DOCS https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#local-lua-debugger-vscode
--------------------------------------------------------------------------------

local adapterDir = vim.env.MASON .. "/packages/local-lua-debugger-vscode"

require("dap").adapters["local-lua"] = {
	type = "executable",
	command = "node",
	args = { "/Users/chrisgrieser/.local/share/nvim/mason/packages/local-lua-debugger-vscode/extension/extension/debugAdapter.js" }, -- SIC 2x extension
	enrich_config = function(config, on_config)
		if not config["extensionPath"] then
			local c = vim.deepcopy(config)
			-- 💀 If this is missing or wrong you'll see
			-- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
			c.extensionPath = "/Users/chrisgrieser/.local/share/nvim/mason/packages/local-lua-debugger-vscode/"
			on_config(c)
		else
			on_config(config)
		end
	end,
}

require("dap").configurations.lua = {
	{
		name = "Launch file",
		type = "local-lua", -- match with `dap.adapters["local-lua"]`
		request = "launch",
		cwd = "${workspaceFolder}",
		program = {
			lua = "lua5.1",
			file = "${file}",
		},
		args = {},
	},
}
