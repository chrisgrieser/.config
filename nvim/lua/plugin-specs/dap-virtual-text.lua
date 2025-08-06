---@module "lazy.core.specs"
---@type LazyPluginSpec
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
		require("dap").listeners.after.event_initialized["dapVirtText"] = dapVirtText.enable
	end,
}
