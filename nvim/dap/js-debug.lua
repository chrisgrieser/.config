-- DOCS https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#vscode-js-debug
--------------------------------------------------------------------------------

local debugServerPath = vim.env.MASON .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
local jsLangs = { "javascript", "typescript" }

--------------------------------------------------------------------------------

require("dap").adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "node",
		args = { debugServerPath, "${port}" },
	},
}

-- INFO for typescript may require extra setup with source-maps
for _, jsLang in pairs(jsLangs) do
	require("dap").configurations[jsLang] = {
		{
			type = "pwa-node", -- matches `dap.adapters.pwa-node`
			request = "launch",
			name = "js-debug: Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
	}
end
