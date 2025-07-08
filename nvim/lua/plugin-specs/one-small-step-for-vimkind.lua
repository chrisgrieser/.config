-- DOCS https://github.com/jbyuki/one-small-step-for-vimkind/
--------------------------------------------------------------------------------

return {
	"jbyuki/one-small-step-for-vimkind",
	commit = "9895b68",


	config = function()
		require("dap").adapters.nlua = function(callback, config)
			callback {
				type = "server",
				host = config.host or "127.0.0.1",
				port = config.port or 8086,
			}
		end
	end,
	keys = {
		{
			"7",
			function()
				if require("dap").status() == "" then
					-- this debugger the only one that needs manual starting, other
					-- debuggers start with `continue` by themselves
					require("osv").run_this()
				else
					require("dap").continue()
				end
			end,
			ft = "lua",
			desc = " Continue (lua version)",
		},
	},
}
