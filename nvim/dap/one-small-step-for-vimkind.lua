-- DOCS https://github.com/jbyuki/one-small-step-for-vimkind/
--------------------------------------------------------------------------------
-- REQUIREMENTS one-small-step-for-vimkind plugin
-- INFO this is just the config for `require("osv").run_this`, which only runs a
-- single self-contained lua file

require("dap").adapters.nlua = function(callback, config)
	callback {
		type = "server",
		host = config.host or "127.0.0.1",
		port = config.port or 8086,
	}
end

vim.notify("🪚 🔲")
--------------------------------------------------------------------------------

require("dap").configurations.lua = {
	{
		type = "nlua",
		request = "attach",
		name = "Attach to running Neovim instance",
	},
}
