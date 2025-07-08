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

		-- auto enable/disable
		require("dap").listeners.after.event_initialized["dapVirtText"] = dapVirtText.enable

		-- local stopEvents = { "event_terminated", "event_exited", "terminate", "disconnect" }
		-- for event, _ in pairs(stopEvents) do
		-- 	require("dap").listeners.after[event]["dapVirtText"] = dapVirtText.disable
		-- end
	end,
}
