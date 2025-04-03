return {
	"rcarriga/nvim-dap-ui",
	dependencies = { "nvim-neotest/nvim-nio", "mfussenegger/nvim-dap" },
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
			desc = " Eval under cursor",
		},
	},
	opts = {
		controls = { enabled = false },
		mappings = {
			expand = { "<Tab>", "<2-LeftMouse>" }, -- 2-LeftMouse = Double Click
			open = "<CR>",
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
		require("dapui").setup(opts)

		-- AUTO-CLOSE THE DAP-UI
		require("dap").listeners.after.disconnect.dapui = require("dapui").close
	end,
}
