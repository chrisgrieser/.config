-- DOCS 
-- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#local-lua-debugger-vscode
-- https://github.com/tomblind/local-lua-debugger-vscode
--------------------------------------------------------------------------------

local adapterDir = vim.env.MASON .. "/share/local-lua-debugger-vscode"
local luaVersion = "luajit" ---@type "luajit"|"lua5.4" -- luajit used by nvim, lua5.4 by hammerspoon

--------------------------------------------------------------------------------

require("dap").adapters["local-lua"] = {
	type = "executable",
	command = "node",
	args = { adapterDir .. "/extension/debugAdapter.js" },
	enrich_config = function(config, on_config)
		if not config["extensionPath"] then
			local c = vim.deepcopy(config)
			c.extensionPath = adapterDir
			on_config(c)
		else
			on_config(config)
		end
	end,
}

require("dap").configurations.lua = {
	{
		name = ("local-lua-debugger: Launch file (%s)"):format(luaVersion),
		type = "local-lua", -- match with `dap.adapters["local-lua"]`
		request = "launch",
		cwd = "${workspaceFolder}",
		program = {
			lua = luaVersion,
			file = "${file}",
		},
	},
}
