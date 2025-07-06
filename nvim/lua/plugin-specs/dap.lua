-- vim: foldlevel=1
--------------------------------------------------------------------------------

local function setupAdapters()
	-- JS-ADAPTER
	-- DOCS https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#vscode-js-debug
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

	-----------------------------------------------------------------------------
	-- DEBUGPY
	-- DOCS https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
	-- also look at: https://github.com/mfussenegger/nvim-dap-python/blob/master/lua/dap-python.lua
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
				local cwd = vim.fn.getcwd()
				if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
					return cwd .. "/venv/bin/python"
				elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
					return cwd .. "/.venv/bin/python"
				else
					return debugpyPython
				end
			end,
		},
	}
end

--------------------------------------------------------------------------------

return {
	"mfussenegger/nvim-dap",
	init = function() vim.g.whichkeyAddSpec { "<leader>d", group = "󰃤 Debugger" } end,
	keys = {
		{ "7", function() require("dap").continue() end, desc = " Continue" },
		{ "8", function() require("dap").toggle_breakpoint() end, desc = " Toggle breakpoint" },
		{
			"<leader>dd",
			function()
				vim.ui.input({ prompt = " Breakpoint condition" }, function(input)
					if not input then return end
					require("dap").set_breakpoint(input)
				end)
			end,
			desc = " Conditional breakpoint",
		},

		{ "<leader>di", function() require("dap").step_in() end, desc = "󰆹 Step in" },
		{ "<leader>dI", function() require("dap").step_out() end, desc = "󰆸 Step out" },
		{ "<leader>do", function() require("dap").step_over() end, desc = " Step over" },
		{ "<leader>dc", function() require("dap").run_to_cursor() end, desc = "󰆿 Run to cursor" },

		{ "<leader>dR", function() require("dap").restart() end, desc = " Restart" },
		{ "<leader>dq", function() require("dap").terminate() end, desc = " Quit" },

		{
			"<leader>db",
			function()
				require("dap").list_breakpoints()
				vim.cmd.cfirst()
			end,
			desc = " Breakpoints to qf",
		},
		-- stylua: ignore
		{ "<leader>d<BS>", function() require("dap").clear_breakpoints() end, desc = "󰅗 Delete breakpoints" },

		-- stylua: ignore
		{ "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "󰫧 Hover variable" },
		{ "q", vim.cmd.close, ft = "dap-float", nowait = true },
		{
			"<leader>ds",
			function()
				local width = math.floor(vim.o.columns * 0.4)
				if not vim.g.dap_sidebar then
					local widgets = require("dap.ui.widgets")
					vim.g.dap_sidebar = widgets.sidebar(widgets.scopes, { width = width })
					vim.g.dap_sidebar.open()
				else
					vim.g.dap_sidebar.close()
					vim.g.dap_sidebar = nil
				end
			end,
			desc = " Scopes sidebar",
		},
		{ "<leader>dr", function() require("dap").repl.toggle() end, desc = " Repl" },
	},
	config = function()
		-- ICONS & HIGHLIGHTS
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "󰇽", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapLogPoint", { text = "󰍩", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapStopped", {
			text = "󰳟",
			texthl = "DiagnosticHint",
			linehl = "DiagnosticVirtualTextHint",
			numhl = "DiagnosticVirtualTextHint",
		})

		-- ADAPTERS
		setupAdapters()

		-- DAP-VIRTUAL-TEXT autostart
		pcall(require, "nvim-dap-virtual-text")

		-- LISTENERS
		-- auto-toggle widgets, and line numbers, and diagnostics
		local listeners = require("dap").listeners.after
		listeners.event_initialized["dap"] = function()
			vim.opt.number = true
			vim.diagnostic.enable(false)
		end
		listeners.event_terminated["dap"] = function()
			vim.opt.number = false
			vim.diagnostic.enable(true)
			if vim.g.dap_sidebar then vim.g.dap_sidebar.close() end
			require("dap").repl.close()
		end
		listeners.event_exited["dap"] = listeners.event_terminated["dap"]

		-- LUALINE COMPONENTS
		-- breakpoint count
		vim.g.lualineAdd("sections", "lualine_y", {
			color = vim.fn.sign_getdefined("DapBreakpoint")[1].texthl,
			function()
				local breakpoints = require("dap.breakpoints").get()
				if #breakpoints == 0 then return "" end
				local allBufs = 0
				for _, bp in pairs(breakpoints) do
					allBufs = allBufs + #bp
				end
				local thisBuf = #(breakpoints[vim.api.nvim_get_current_buf()] or {})
				local countStr = (thisBuf == allBufs) and thisBuf or thisBuf .. "/" .. allBufs
				local icon = vim.fn.sign_getdefined("DapBreakpoint")[1].text
				return icon .. countStr
			end,
		}, "before")

		-- status
		vim.g.lualineAdd("tabline", "lualine_z", { require("dap").status, icon = "󰃤" })
	end,
}
