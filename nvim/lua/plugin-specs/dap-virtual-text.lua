return {
	"theHamsta/nvim-dap-virtual-text",
	opts = {
		highlight_changed_variables = true,
		highlight_new_as_changed = true,
		only_first_definition = false,
		all_references = false,
	},
	config = function(_, opts)
		local dapVirtText = require("nvim-dap-virtual-text")
		dapVirtText.setup(opts)

		-- auto-enable and auto-disable
		require("dap").listeners.after.initialize["dapVirtText"] = dapVirtText.enable
		require("dap").listeners.after.terminate["dapVirtText"] = dapVirtText.disable
	end,
}
