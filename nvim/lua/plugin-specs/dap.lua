local function dapConfig()
	-- SIGN-ICONS & HIGHLIGHTS
	vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
	vim.fn.sign_define("DapStopped", {
		text = "",
		texthl = "DiagnosticHint",
		linehl = "DiagnosticVirtualTextHint",
	})
	vim.fn.sign_define("DapBreakpointRejected", {
		text = "",
		texthl = "DiagnosticError",
		linehl = "DiagnosticVirtualTextError",
	})

	-- AUTO-OPEN/CLOSE THE DAP-UI
	local listener = require("dap").listeners.before
	local function start()
		require("dapui").open()
		vim.wo.number = true
	end
	listener.attach.dapui_config = function() require("dapui").open() end
	listener.launch.dapui_config = function() require("dapui").open() end
	listener.event_terminated.dapui_config = function() require("dapui").close() end
	listener.event_exited.dapui_config = function() require("dapui").close() end

	-- LUALINE COMPONENTS
	vim.g.lualineAdd("sections", "lualine_y", {
		color = vim.fn.sign_getdefined("DapBreakpoint")[1].texthl,
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
	}, "before")
	vim.g.lualineAdd("tabline", "lualine_z", function()
		local dapStatus = require("dap").status()
		if dapStatus == "" then return "" end
		return "󰃤 " .. dapStatus
	end)
end

--------------------------------------------------------------------------------

return {
	{
		"mfussenegger/nvim-dap",
		keys = {
			{ "8", function() require("dap").continue() end, desc = " Continue" },
			{ "7", function() require("dap").toggle_breakpoint() end, desc = " Toggle breakpoint" },
			-- stylua: ignore
			{ "<leader>dc", function() require("dap").clear_breakpoints() end, desc = " Clear all breakpoints" },
			{ "<leader>dr", function() require("dap").restart() end, desc = " Restart" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = " Terminate" },
		},
		init = function() vim.g.whichkeyAddSpec { "<leader>d", group = "󰃤 Debugger" } end,
		config = dapConfig,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		keys = {
			{ "<leader>du", function() require("dapui").toggle() end, desc = "󱂬 dap-ui" },
			{
				"<leader>di",
				function() require("dapui").float_element("repl", { enter = true }) end, ---@diagnostic disable-line: missing-fields
				desc = " REPL",
			},
			{
				"<leader>dl",
				function() require("dapui").float_element("breakpoints", { enter = true }) end, ---@diagnostic disable-line: missing-fields
				desc = " List breakpoints",
			},
			{
				"<leader>de",
				function() require("dapui").eval() end,
				mode = { "n", "x" },
				desc = " Eval",
			},
		},
		opts = {
			controls = {
				enabled = true,
				element = "scopes",
			},
			mappings = {
				expand = { "<Tab>", "<2-LeftMouse>" }, -- 2-LeftMouse = Double Click
				open = "<CR>",
			},
			floating = {
				border = vim.g.borderStyle,
				mappings = { close = { "q", "<Esc>", "<D-w>" } },
			},
			layouts = {
				{
					position = "right",
					size = 40, -- width
					elements = {
						{ id = "scopes", size = 0.8 }, -- Variables
						{ id = "stacks", size = 0.2 }, -- stracktracing
						-- { id = "watches", size = 0.15 }, -- Expressions
					},
				},
			},
		},
	},
	{ -- debugger for nvim-lua
		"jbyuki/one-small-step-for-vimkind",
		dependencies = "mfussenegger/nvim-dap",
		config = function()
			require("dap").configurations.lua = {
				{ type = "nlua", request = "attach", name = "Attach to running Neovim instance" },
			}
			require("dap").adapters.nlua = function(callback, config)
				callback {
					type = "server",
					host = config.host or "127.0.0.1", ---@diagnostic disable-line: undefined-field
					port = config.port or 8086, ---@diagnostic disable-line: undefined-field
				}
			end
		end,
		keys = {
			-- INFO this debugger the only one that needs manual starting, other
			-- debuggers start with `continue` by themselves
			{
				"<leader>dn",
				function() require("osv").run_this() end,
				ft = "lua",
				desc = " Start (nvim-lua debugger)",
			},
		},
	},

	-----------------------------------------------------------------------------
	-- INFO also needs to add `debugpy` to `mason`
	{ -- debugger preconfig for python
		"mfussenegger/nvim-dap-python",
		enabled = false,
		ft = "python",
		config = function()
			-- 1. use the debugypy installation by mason
			-- 2. deactivate the annoying auto-opening the console by redirecting
			-- to the internal console
			local debugpyPythonPath = require("mason-registry")
				.get_package("debugpy")
				:get_install_path() .. "/venv/bin/python3"
			require("dap-python").setup(debugpyPythonPath, { console = "internalConsole" }) ---@diagnostic disable-line: missing-fields
		end,
	},
}
