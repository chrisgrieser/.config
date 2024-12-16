return {
	"jbyuki/one-small-step-for-vimkind",
	dependencies = "mfussenegger/nvim-dap",
	config = function()
		require("dap").configurations.lua = {
			{ type = "nlua", request = "attach", name = "Attach to running Neovim instance" },
		}
		require("dap").adapters.nlua = function(callback, config)
			callback {
				type = "server",
				host = config.host or "127.0.0.1", ---@diagnostic disable-line: undefined-field
				port = config.port or 8086, ---@diagnostic disable-line: undefined-field
			}
		end
	end,
	-- INFO this debugger the only one that needs manual starting, other
	-- debuggers start with `continue` by themselves
	keys = {
		-- 1. Two nvim instances, one for debuggee and one for debugger
		--   a) `require("osv").launch` must be used on debuggee-instance
		--   b) breakpoints must be set in debugger-instance
		{
			"<leader>dl",
			function() require("osv").launch() end,
			ft = "lua",
			desc = " Use instance as debuggee",
		},
		-- 2. One nvim instance, runs current file via * `require("osv").run_this`
		-- less flexible, but quicker to start. Useful just to check code samples.
		{
			"7",
			function()
				if require("dap").status() == "" then
					require("osv").run_this()
				else
					require("dap").continue()
				end
			end,
			ft = "lua",
			desc = " Continue (lua)",
		},
	},
}

