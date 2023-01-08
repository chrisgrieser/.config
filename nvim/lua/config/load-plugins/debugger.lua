local function dapConfig()
	local dap = require("dap")
	local dataPath = vim.fn.stdpath("data")
	--------------------------------------------------------------------------------

	-- DAP SETUP
	-- INFO: uses dap-names, not mason-names https://github.com/jayp0521/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
	require("mason-nvim-dap").setup {
		ensure_installed = { "node2" },
	}

	--------------------------------------------------------------------------------
	-- CONFIGURATION OF SPECIFIC DEBUGGERS
	-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

	-- Lua (one-step-for-vimkind plugin)
	dap.configurations.lua =
		{ {
			type = "nlua",
			request = "attach",
			name = "Attach to running Neovim instance",
		} }

	dap.adapters.nlua = function(callback, config)
		callback { type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 }
	end

	-- Node2
	-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#javascript
	dap.adapters.node2 = {
		type = "executable",
		command = "node",
		args = {
			dataPath .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js",
		},
	}

	dap.configurations.javascript = {
		{
			name = "Launch",
			type = "node2",
			request = "launch",
			program = "${file}",
			cwd = vim.fn.getcwd(),
			sourceMaps = true,
			protocol = "inspector",
			console = "integratedTerminal",
		},
		{
			name = "Attach to process",
			type = "node2",
			request = "attach",
			processId = require("dap.utils").pick_process,
		},
	}

	--------------------------------------------------------------------------------
	-- DAP-RELATED PLUGINS
	require("nvim-dap-virtual-text").setup()
	require("dapui").setup()

	--------------------------------------------------------------------------------
	-- KEYBINDINGS

	vim.keymap.set("n", "7", function()
		-- HACK wrap `continue` in this, since the nvim-lua-debugger has to be started separately
		local dapRunning = dap.status() ~= ""
		if not dapRunning and vim.bo.filetype == "lua" then
			require("osv").run_this()
		else
			dap.continue()
		end
		vim.api.nvim_set_option_value("number", true, { scope = "local" })
	end, { desc = " Continue" })

	-- selection of dap-commands
	vim.keymap.set("n", "<leader>b", function()
		local selection = {
			"Toggle DAP UI",
			"Terminate",
			"Set Log Point",
			"Clear Breakpoints",
			"Conditional Breakpoint",
			"Step over",
			"Step into",
			"Step out",
			"Run to Cursor",
		}
		vim.ui.select(selection, { prompt = " DAP Command" }, function(choice)
			if not choice then return end
			if choice:find("^Launch") then
				vim.api.nvim_set_option_value("number", true, { scope = "local" })
			end

			if choice == "Toggle DAP UI" then
				require("dapui").toggle()
			elseif choice == "Step over" then
				dap.step_over()
			elseif choice == "Step into" then
				dap.step_into()
			elseif choice == "Step out" then
				dap.step_out()
			elseif choice == "Run to Cursor" then
				dap.run_to_cursor()
			elseif choice == "Clear Breakpoints" then
				dap.clear_breakpoints()
			elseif choice == "Conditional Breakpoint" then
				vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
					if not cond then return end
					dap.set_breakpoint(cond)
				end)
			elseif choice == "Log Point" then
				vim.ui.input({ prompt = "Log point message: " }, function(msg)
					if not msg then return end
					dap.set_breakpoint(nil, nil, msg)
				end)
			elseif choice == "Terminate" then
				vim.api.nvim_set_option_value("number", false, { scope = "local" })
				require("dapui").close()
				dap.terminate()
			end
		end)
	end, { desc = " Select Action" })

	--------------------------------------------------------------------------------
	-- SIGN-COLUMN ICONS
	local sign = vim.fn.sign_define
	sign("DapBreakpoint", { text = "", texthl = "DiagnosticHint" })
	sign("DapBreakpointCondition", { text = "", texthl = "DiagnosticHint" })
	sign("DapLogPoint", { text = "", texthl = "DiagnosticHint" })
	sign("DapStopped", { text = "", texthl = "DiagnosticInfo" })
	sign("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
end

local function dapLualine()
	local topSeparators = isGui() and { left = "", right = "" } or { left = "", right = "" }
	require("lualine").setup {
		extensions = { "nvim-dap-ui" },
		winbar = {
			lualine_z = {
				{
					function()
						local dapStatus = require("dap").status()
						if dapStatus == "" then return "" end
						return "  " .. dapStatus
					end,
					section_separators = topSeparators,
				},
			},
		},
	}
end
--------------------------------------------------------------------------------

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"jayp0521/mason-nvim-dap.nvim",
		"theHamsta/nvim-dap-virtual-text",
		"rcarriga/nvim-dap-ui",
		"jbyuki/one-small-step-for-vimkind", -- lua debugger specifically for neovim config
	},
	keys = {
		{ "7", nil, desc = " Continue" },
		{ "<leader>b", nil, desc = " Select Action" },
	},
	config = function()
		dapConfig()
		dapLualine()
	end,
}
