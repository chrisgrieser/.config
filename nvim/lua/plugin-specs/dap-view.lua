-- DOCS https://igorlfs.github.io/nvim-dap-view/configuration
-- Alternative: https://github.com/miroshQa/debugmaster.nvim
--------------------------------------------------------------------------------

return {
	"igorlfs/nvim-dap-view",
	dependencies = "mfussenegger/nvim-dap",
	keys = {
		{ "<leader>du", function() require("dap-view").toggle() end, desc = "󱂬 Toggle UI" },
		{ "<leader>db", function() require("dap-view").toggle() end, desc = "󱂬 Toggle UI" },
	},

	---@module "dap-view"
	---@type dapview.Config
	opts = {
		auto_toggle = false,
		winbar = {
			-- stylua: ignore
			sections = { "scopes", "breakpoints", "watches", "exceptions", "threads", "repl", "console" },
			default_section = "scopes",
			controls = { enabled = true },
		},
		windows = { height = 12, position = "below" },
	},
	config = function(_, opts)
		require("dap-view").setup(opts)

		-- AUTO-CLOSE THE UI
		require("dap").listeners.after.disconnect["dap-view"] = require("dap-view").close
	end,
}
