return {
	"jbyuki/one-small-step-for-vimkind",
	commit = "d9f8325", -- PENDING https://github.com/jbyuki/one-small-step-for-vimkind/issues/81

	dependencies = "mfussenegger/nvim-dap", -- loads dap config as well
	config = function() end,
	keys = {
		{
			"7",
			function()
				if require("dap").status() == "" then
					-- INFO this debugger the only one that needs manual starting, other
					-- debuggers start with `continue` by themselves
					require("osv").run_this() -- starts single file
				else
					require("dap").continue()
				end
			end,
			ft = "lua",
			desc = " Continue (lua version)",
		},
	},
}
