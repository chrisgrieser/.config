return {
	"theHamsta/nvim-dap-virtual-text",
	opts = {
		highlight_changed_variables = true,
		highlight_new_as_changed = false,
		only_first_definition = false,
		all_references = false,
	},
	config = function(_, opts)
		local dapVirtText = require("nvim-dap-virtual-text")
		dapVirtText.setup(opts)

		-- auto enable/disable
		require("dap").listeners.after.event_initialized["dapVirtText"] = dapVirtText.enable
		require("dap").listeners.after.event_terminated["dapVirtText"] = dapVirtText.disable
		require("dap").listeners.after.event_exited["dapVirtText"] = dapVirtText.disable
	end,
	init = function ()
		-- highlights
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: Change `NvimDapVirtualText` color",
			callback = function()
				vim.api.nvim_set_hl(0, "NvimDapVirtualText", { link = "DiagnosticSignInfo" })
			end,
		})
	end,
}
