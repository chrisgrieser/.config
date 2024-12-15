return {
	"theHamsta/nvim-dap-virtual-text",
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
		local dapvt = require("nvim-dap-virtual-text")
		dapvt.setup(opts)

		-- auto-disable/enable
		local listeners = require("dap").listeners.after
		listeners.attach.dapvt = dapvt.enable
		listeners.launch.dapvt = dapvt.enable
		listeners.disconnect.dapvt = dapvt.disable
		listeners.event_terminated.dapvt = dapvt.disable
		listeners.event_exited.dapvt = dapvt.disable
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

