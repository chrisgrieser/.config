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

		-- auto-enable
		require("dap").listeners.after.initialize["nvim-dap-virtual-text"] = dapVirtText.enable
	end,
}
