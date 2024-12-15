return {
	{ -- DAP
		"mfussenegger/nvim-dap",
		dependencies = { "rcarriga/nvim-dap-ui", "theHamsta/nvim-dap-virtual-text" },
		keys = {
			{ "7", function() require("dap").continue() end, desc = " Continue" },
			{ "8", function() require("dap").toggle_breakpoint() end, desc = " Toggle breakpoint" },
			-- stylua: ignore
			{ "<leader>dc", function() require("dap").clear_breakpoints() end, desc = " Clear all breakpoints" },
			{ "<leader>dr", function() require("dap").restart() end, desc = " Restart" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = " Terminate" },
		},
		init = function() vim.g.whichkeyAddSpec { "<leader>d", group = "󰃤 Debugger" } end,
		config = function()
			-- SIGN-ICONS & HIGHLIGHTS
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapStopped", {
				text = "",
				texthl = "DiagnosticHint",
				linehl = "DiagnosticVirtualTextHint",
				numhl = "DiagnosticVirtualTextHint",
			})

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
		end,
	},
	{ -- DAP-VIRTUAL-TEXT
		"theHamsta/nvim-dap-virtual-text",
		opts = {
			highlight_changed_variables = true,
			highlight_new_as_changed = true,
			only_first_definition = false,
			all_references = false,
			clear_on_continue = false,
		},
		config = function(_, opts)
			require("nvim-dap-virtual-text").setup(opts)

			require("dap").listeners.after.disconnect.dapui = function()
				require("nvim-dap-virtual-text").disable()
			end

			-- change color
			vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
				desc = "User: Change `NvimDapVirtualText` color",
				callback = function()
					vim.api.nvim_set_hl(0, "NvimDapVirtualText", { link = "DiagnosticSignInfo" })
				end,
			})
		end,
	},
	{ -- DAP-UI
		"rcarriga/nvim-dap-ui",
		dependencies = "nvim-neotest/nvim-nio",
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
		config = function(_, opts)
			require("dapui").setup(opts)

			-- AUTO-OPEN/CLOSE THE DAP-UI
			local function start()
				require("dapui").open()
				vim.wo.number = true
			end
			local function stop()
				require("dapui").close()
				vim.wo.number = false
			end
			require("dap").listeners.after.attach.dapui = start
			require("dap").listeners.after.launch.dapui = start
			require("dap").listeners.after.disconnect.dapui = stop
			require("dap").listeners.after.event_terminated.dapui = stop
			require("dap").listeners.after.event_exited.dapui = stop
		end,
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
						{ id = "stacks", size = 0.2 }, -- stracktrace
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
		-- INFO this debugger the only one that needs manual starting, other
		-- debuggers start with `continue` by themselves
		keys = {
			-- 1. Two nvim instances, one for debuggee and one for debugger
			--   a) `require("osv").launch` must be used on debuggee-instance
			--   b) breakpoints must be set in debugger-instance
			{
				"<leader>dl",
				function() require("osv").launch { port = 8086 } end,
				ft = "lua",
				desc = " Use this nvim instance as debuggee",
			},
			-- 2. One nvim instance, runs current file via * `require("osv").run_this`
			-- less flexible, but quicker to start. Useful just to check code samples.
			{
				"7",
				function()
					if require("dap").status() == "" then
						require("osv").run_this()
					else
						require("dap").continue()
					end
				end,
				ft = "lua",
				desc = " Continue (lua)",
			},
		},
	},

	-- INFO also needs to add `debugpy` to `mason`
	{ -- debugger preconfig for python
		"mfussenegger/nvim-dap-python",
		ft = "python",
		config = function()
			-- 1. use the debugypy installation by mason
			-- 2. deactivate auto-opening the console by redirecting to internal console
			local debugpyPythonPath = require("mason-registry")
				.get_package("debugpy")
				:get_install_path() .. "/venv/bin/python3"
			require("dap-python").setup(debugpyPythonPath, { console = "internalConsole" }) ---@diagnostic disable-line: missing-fields
		end,
	},
}
