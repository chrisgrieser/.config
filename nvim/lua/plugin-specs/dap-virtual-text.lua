return {
	"theHamsta/nvim-dap-virtual-text",
	dependencies = "mfussenegger/nvim-dap",
	opts = {
		highlight_changed_variables = true,
		highlight_new_as_changed = false,
		only_first_definition = false,
		all_references = false,
	},
	keys = {
		{
			"<leader>dv",
			function() require("nvim-dap-virtual-text").toggle() end,
			desc = "󱂬 Toggle virtual text",
		},
	},
	config = function(_, opts)
		local dapVirtText = require("nvim-dap-virtual-text")
		dapVirtText.setup(opts)

		-- auto-disable/enable
		local listeners = require("dap").listeners.after
		listeners.disconnect.dapVirtText = dapVirtText.disable
		listeners.event_terminated.dapVirtText = dapVirtText.disable
		listeners.event_exited.dapVirtText = dapVirtText.disable
	end,
	init = function()
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: Change `NvimDapVirtualText` color",
			callback = function()
				vim.api.nvim_set_hl(0, "NvimDapVirtualText", { link = "DiagnosticSignInfo" })
			end,
		})
	end,
}

