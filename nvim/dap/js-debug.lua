-- DOCS https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#vscode-js-debug
--------------------------------------------------------------------------------

local jsDebugAdapterPath = vim.env.MASON
	.. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
require("dap").adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "node",
		args = { jsDebugAdapterPath, "${port}" },
	},
}
-- INFO for typescript may require extra setup with source-maps
for _, jsLang in pairs { "javascript", "typescript" } do
	require("dap").configurations[jsLang] = {
		{
			type = "pwa-node", -- matches `dap.adapters.pwa-node`
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
	}
end
