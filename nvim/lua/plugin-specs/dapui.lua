return {
	"rcarriga/nvim-dap-ui",
	dependencies = "nvim-neotest/nvim-nio",
	keys = {
		{ "<leader>du", function() require("dapui").toggle() end, desc = "󱂬 Toggle UI" },
		{
			"<leader>db",
			function() require("dapui").float_element("breakpoints", { enter = true }) end, ---@diagnostic disable-line: missing-fields
			desc = " List breakpoints",
		},
		{
			"<leader>de",
			function() require("dapui").eval() end,
			mode = { "n", "x" },
			desc = " Eval", -- value under cursor
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
		},
		layouts = {
			{
				position = "right",
				size = 40, -- = width
				elements = {
					{ id = "scopes", size = 0.8 },
					{ id = "stacks", size = 0.2 },
				},
			},
		},
	},
	config = function(_, opts)
		local dapui = require("dapui")
		dapui.setup(opts)

		-- AUTO-CLOSE THE DAP-UI
		local listeners = require("dap").listeners.after
		listeners.disconnect.dapui = dapui.close
		listeners.event_terminated.dapui = dapui.close
		listeners.event_exited.dapui = dapui.close
	end,
}
