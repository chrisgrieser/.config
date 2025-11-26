-- DOCS https://github.com/tomblind/local-lua-debugger-vscode
-- setup in nvim: https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#local-lua-debugger-vscode
-- debug in nvim-lua: https://zignar.net/2023/06/10/debugging-lua-in-neovim/
--------------------------------------------------------------------------------

local dapServerPath = vim.env.MASON .. "/share/local-lua-debugger-vscode"

--------------------------------------------------------------------------------

require("dap").adapters["local-lua"] = {
	type = "executable",
	command = "node",
	args = { dapServerPath .. "/extension/debugAdapter.js" },
	enrich_config = function(config, on_config)
		if not config["extensionPath"] then
			local c = vim.deepcopy(config)
			-- 💀 If this is missing or wrong you'll see
			-- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
			c.extensionPath = dapServerPath
			on_config(c)
		else
			on_config(config)
		end
	end,
}

require("dap").configurations.lua = {
	{
		name = "Current file (local-lua-dbg, nlua)",
		type = "local-lua", -- matches `dap.adapters.local-lua`
		request = "launch",
		cwd = "${workspaceFolder}",
		program = {
			lua = "nlua.lua",
			file = "${file}",
		},
		verbose = true,
		args = {},
	},
}

--------------------------------------------------------------------------------
