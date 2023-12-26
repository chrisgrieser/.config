local u = require("config.utils")

--------------------------------------------------------------------------------

local function dapLualine()
	local breakpointHl = vim.fn.sign_getdefined("DapBreakpoint")[1].texthl
	local breakpointFg = u.getHighlightValue(breakpointHl, "fg")
	u.addToLuaLine("sections", "lualine_y", {
		color = { fg = breakpointFg },
		function()
			local breakpoints = require("dap.breakpoints").get()
			local breakpointSum = 0
			for buf, _ in pairs(breakpoints) do
				breakpointSum = breakpointSum + #breakpoints[buf]
			end
			if breakpointSum == 0 then return "" end
			local breakpointIcon = vim.fn.sign_getdefined("DapBreakpoint")[1].text
			return breakpointIcon .. tostring(breakpointSum)
		end,
	})
	u.addToLuaLine("sections", "lualine_x", function()
		local dapStatus = require("dap").status()
		return dapStatus ~= "" and "  " .. dapStatus or ""
	end)

	require("config.theme-customization").reloadTheming()
end

local function dapSigns()
	local sign = vim.fn.sign_define

	local hintBg = u.getHighlightValue("DiagnosticVirtualTextHint", "bg")
	vim.api.nvim_set_hl(0, "DapBreak", { bg = hintBg })
	sign("DapStopped", { text = "", texthl = "DiagnosticHint", linehl = "DapBreak" })

	sign("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
	sign("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
	sign("DapLogPoint", { text = "", texthl = "DiagnosticInfo" })
	sign("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
end

local function terminateCallback() require("dapui").close() end

local function setupDapListeners()
	local listener = require("dap").listeners
	listener.after.event_initialized["dapui_config"] = function() require("dapui").open() end
	listener.before.event_terminated["dapui_config"] = terminateCallback
	listener.before.event_exited["dapui_config"] = terminateCallback
end

--------------------------------------------------------------------------------

return {
	{
		"mfussenegger/nvim-dap",
		keys = {
			-- INFO toggling breakpoints and "Continue" command done via nvim-recorder
			-- stylua: ignore start
			{ "<leader>bc", function() require("dap").run_to_cursor() end, desc = "󰇀 Run to Cursor" },
			{ "<leader>bd", function() require("dap").clear_breakpoints() end, desc = " Remove Breakpoints" },
			{ "<leader>br", function() require("dap").restart() end, desc = " Restart" },
			{ "<leader>bt", function() require("dap").terminate({}, {}, terminateCallback) end, desc = " Terminate" },
			-- stylua: ignore end
		},
		init = function() u.leaderSubkey("b", " Debugger") end,
		config = function()
			dapSigns()
			dapLualine()
			setupDapListeners()
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = "mfussenegger/nvim-dap",
		keys = {
			{ "<leader>bu", function() require("dapui").toggle() end, desc = "󱂬 Toggle DAP-UI" }, -- codespell-ignore
			{
				"<leader>bl",
				function() require("dapui").float_element("breakpoints") end,
				desc = " List Breakpoints",
			},
			{
				"<leader>bi",
				function() require("dapui").float_element("repl") end,
				mode = { "n", "x" },
				desc = " REPL",
			},
			{
				"<leader>bb",
				function() require("dapui").eval() end,
				mode = { "n", "x" },
				desc = " Eval",
			},
		},
		opts = {
			controls = { enabled = false, element = "scopes" },
			floating = { border = u.borderStyle },
			layouts = {
				{
					position = "right",
					size = 40,
					elements = {
						{ id = "scopes", size = 0.8 },
						{ id = "stacks", size = 0.2 },
						-- { id = "watches", size = 0.15 },
					},
				},
			},
		},
	},

	-----------------------------------------------------------------------------
	{
		"jbyuki/one-small-step-for-vimkind",
		dependencies = "mfussenegger/nvim-dap",
		config = function()
			require("dap").configurations.lua = {
				{ type = "nlua", request = "attach", name = "Attach to running Neovim instance" },
			}
			require("dap").adapters.nlua = function(callback, config)
				callback {
					type = "server",
					host = config.host or "127.0.0.1",
					port = config.port or 8086,
				}
			end
		end,
		keys = {
			-- INFO is the only one that needs manual starting, other debuggers
			-- start with `continue` by themselves
			{ "<leader>bn", function() require("osv").run_this() end, desc = " nvim-lua debugger" },
		},
	},
	{ -- debugger preconfig for python
		"mfussenegger/nvim-dap-python",
		ft = "python",
		config = function()
			-- 1. use the debugypy installation by mason
			-- 2. deactivate the annoying auto-opening the console by redirecting
			-- to the internal console
			local debugpyPythonPath = require("mason-registry")
				.get_package("debugpy")
				:get_install_path() .. "/venv/bin/python3"
			require("dap-python").setup(debugpyPythonPath, { console = "internalConsole" })
		end,
	},
}
