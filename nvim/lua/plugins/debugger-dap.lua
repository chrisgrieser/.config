local u = require("config.utils")

--------------------------------------------------------------------------------

local function dapLualine()
	u.addToLuaLine("tabline", "lualine_y", function ()
		local dapStatus = require("dap").status()
		if dapStatus ~= "" then dapStatus = "  " .. dapStatus end
		return dapStatus
	end)
	u.addToLuaLine("tabline", "lualine_z", function ()
		local breakpoints = require("dap.breakpoints").get()
		local breakpointSum = 0
		for buf, _ in pairs(breakpoints) do
			breakpointSum = breakpointSum + #breakpoints[buf]
		end
		if breakpointSum == 0 then return "" end
		return " " .. tostring(breakpointSum)
	end)

	require("config.theme-customization").reloadTheming()
end

local function dapSigns()
	local sign = vim.fn.sign_define
	sign("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
	sign("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
	sign("DapLogPoint", { text = "󰍨", texthl = "DiagnosticInfo" })
	sign("DapStopped", { text = "󰏧", texthl = "DiagnosticHint" })
	sign("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
end

local function terminateCallback() require("dapui").close() end

local function setupDapListeners()
	local listener = require("dap").listeners
	listener.after.event_initialized["dapui_config"] = function() require("dapui").open() end
	listener.before.event_terminated["dapui_config"] = terminateCallback
	listener.before.event_exited["dapui_config"] = terminateCallback
end

--------------------------------------------------------------------------------

-- TODO https://github.com/mfussenegger/nvim-dap-python
-- { "mfussenegger/nvim-dap-python" },
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
			{ "<leader>bq", function() require("dap").list_breakpoints() end, desc = " Breakpoints to QuickFix"},
			-- stylua: ignore end
		},
		dependencies = { "theHamsta/nvim-dap-virtual-text", "jayp0521/mason-nvim-dap.nvim" },
		init = function() u.leaderSubkey("b", " Debugger") end,
		config = function()
			dapLualine()
			dapSigns()
			setupDapListeners()
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		opts = { only_first_definition = true },
		init = function() u.colorschemeMod("NvimDapVirtualText", { link = "DiagnosticVirtualTextInfo" }) end,
	},
	{
		"rcarriga/nvim-dap-ui",
		keys = {
			{ "<leader>bu", function() require("dapui").toggle() end, desc = "󱂬 Toggle DAP-UI" },
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
			controls = { enabled = false },
			floating = { border = require("config.utils").borderStyle },
			layouts = {
				{
					position = "right",
					size = 35,
					elements = {
						{ id = "scopes", size = 0.8 },
						{ id = "stacks", size = 0.2 },
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
			local dap = require("dap")
			dap.configurations.lua = {
				{ type = "nlua", request = "attach", name = "Attach to running Neovim instance" },
			}
			dap.adapters.nlua = function(callback, config)
				callback { type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 }
			end
		end,
		keys = {
			{
				"<leader>bn",
				function()
					-- INFO is the only one that needs manual starting, other debuggers
					-- start with `continue` by themselves
					if not vim.bo.filetype == "lua" then
						vim.notify("Not a lua file.", vim.log.levels.WARN)
						return
					end
					require("osv").run_this()
				end,
				desc = "  nvim-lua debugger",
			},
		},
	},
}
