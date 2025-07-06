-- DOCS https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
-- also look at: https://github.com/mfussenegger/nvim-dap-python/blob/master/lua/dap-python.lua
-----------------------------------------------------------------------------

local debugpyPython = vim.env.MASON .. "/packages/debugpy/venv/bin/python"

require("dap").adapters.python = function(cb, config)
	if config.request == "attach" then
		local port = (config.connect or config).port
		local host = (config.connect or config).host or "127.0.0.1"
		cb {
			type = "server",
			port = assert(port, "`connect.port` is required for a python `attach` configuration"),
			host = host,
			options = { source_filetype = "python" },
		}
	else
		cb {
			type = "executable",
			command = debugpyPython,
			args = { "-m", "debugpy.adapter" },
			options = { source_filetype = "python" },
		}
	end
end

require("dap").configurations.python = {
	{
		type = "python", -- match with `dap.adapters.python`
		request = "launch",
		name = "Launch file",

		-- debugpy options https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
		program = "${file}",
		pythonPath = function()
			-- debugpy supports launching an application with a different
			-- interpreter then the one used to launch debugpy itself.
			local venvPython = vim.fn.getcwd() .. "/.venv/bin/python"
			return (vim.fn.executable(venvPython) == 1 and venvPython or debugpyPython)
		end,
	},
}

