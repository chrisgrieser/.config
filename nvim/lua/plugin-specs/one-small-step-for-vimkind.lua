-- DOCS https://github.com/jbyuki/one-small-step-for-vimkind/
--------------------------------------------------------------------------------

return {
	"jbyuki/one-small-step-for-vimkind",
	commit = "84689d9", -- PENDING https://github.com/jbyuki/one-small-step-for-vimkind/issues/81

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
					require("osv").run_this() -- `run_this` needs manual starting
				else
					require("dap").continue()
				end
			end,
			ft = "lua",
			desc = " Continue / Run file",
		},
	},
}
