local function dapConfig()
	local dap = require("dap")
	--------------------------------------------------------------------------------
	-- DAP SETUP
	-- INFO: uses dap-names, not mason-names https://github.com/jayp0521/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
	require("mason-nvim-dap").setup {}

	-----------------------------------------------------------------------------
	-- CONFIGURATION OF SPECIFIC DEBUGGERS

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

	--------------------------------------------------------------------------------
	-- DAP-RELATED PLUGINS
	require("nvim-dap-virtual-text").setup()
	require("dapui").setup()

	--------------------------------------------------------------------------------
	-- KEYBINDINGS
	-- INFO toggling breakpoints already done via nvim-recorder

	-- selection of dap-commands
	vim.keymap.set("n", "<leader>b", function()
		local selection = {
			"Toggle DAP UI",
			"Start nvim-lua debugger",
			"Terminate",
			"Set Log Point",
			"Clear Breakpoints",
			"Conditional Breakpoint",
			"Add Breakpoints to Quickfix List",
			"Step over",
			"Step into",
			"Step out",
			"Run to Cursor",
		}
		vim.ui.select(selection, { prompt = " DAP Command" }, function(choice)
			if not choice then return end

			if choice == "Toggle DAP UI" then
				require("dapui").toggle()
			elseif choice == "Step over" then
				dap.step_over()
			elseif choice == "Start nvim-lua debugger" then
				vim.api.nvim_set_option_value("number", true, { scope = "local" })
				-- INFO is the only one that needs manual starting, other debuggers
				-- start with `continue` by themselves
				local dapRunning = dap.status() ~= ""
				if dapRunning then
					vim.notify("Debugger already running.", vim.log.levels.WARN)
				elseif not vim.bo.filetype == "lua" then
					vim.notify("Not a lua file.", vim.log.levels.WARN)
				else
					require("osv").run_this() -- start lua debugger
				end
			elseif choice == "Step into" then
				dap.step_into()
			elseif choice == "Step out" then
				dap.step_out()
			elseif choice == "Run to Cursor" then
				dap.run_to_cursor()
			elseif choice == "Clear Breakpoints" then
				dap.clear_breakpoints()
			elseif choice == "Add Breakpoints to Quickfix List" then
				dap.list_breakpoints()
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
	sign("DapLogPoint", { text = "󰍨", texthl = "DiagnosticHint" })
	sign("DapStopped", { text = "", texthl = "DiagnosticInfo" })
	sign("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
end

local function dapLualine()
	local topSeparators = vim.g.neovide and { left = "", right = "" } or { left = "", right = "" }

	-- INFO inserting needed, to not disrupt existing lualine-segment set by nvim-recorder
	local lualineY = require("lualine").get_config().winbar.lualine_y or {}
	local lualineZ = require("lualine").get_config().winbar.lualine_z or {}
	table.insert(lualineY, {
		function()
			local breakpoints = require("dap.breakpoints").get()
			local breakpointSum = 0
			for buf, _ in pairs(breakpoints) do
				breakpointSum = breakpointSum + #breakpoints[buf]
			end
			if breakpointSum == 0 then return "" end
			return "  " .. tostring(breakpointSum)
		end,
		section_separators = topSeparators,
	})
	table.insert(lualineZ, {
		function()
			local dapStatus = require("dap").status()
			if dapStatus ~= "" then dapStatus = "  " .. dapStatus end
			return dapStatus
		end,
		section_separators = topSeparators,
	})

	require("lualine").setup {
		extensions = { "nvim-dap-ui" },
		winbar = {
			lualine_y = lualineY,
			lualine_z = lualineZ,
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
		{ "<leader>b", desc = " Select Action" },
	},
	config = function()
		dapConfig()
		dapLualine()
	end,
}
