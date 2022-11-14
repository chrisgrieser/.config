require("utils")
local dap = require("dap")
--------------------------------------------------------------------------------
-- INFO: setup descriptions
-- https://github.com/mxsdev/nvim-dap-vscode-js#setup
-- https://github.com/jbyuki/one-small-step-for-vimkind
--------------------------------------------------------------------------------

require("mason-nvim-dap").setup {
	-- INFO: uses dap-names, not mason-names https://github.com/jayp0521/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
	ensure_installed = {
		-- "bash",
		-- "node2",
		-- "js",
		-- "chrome",
	},
	-- one-step-for-vimkind not included with mason
	automatic_setup = true,
}


--------------------------------------------------------------------------------

-- Lua (one-step-for-vimkind plugin)
dap.configurations.lua = {{
	type = "nlua",
	request = "attach",
	name = "Attach to running Neovim instance",
}}

dap.adapters.nlua = function(callback, config)
	callback {type = "server", host = config.host or "127.0.0.1", port = config.port or 8086}
end

--------------------------------------------------------------------------------

require("nvim-dap-virtual-text").setup()


--------------------------------------------------------------------------------

keymap("n", "<leader>bb", dap.continue)
keymap("n", "<leader>bp", dap.toggle_breakpoint)
keymap("n", "<leader>bs", dap.step_over)
keymap("n", "<leader>bi", dap.step_into)
keymap("n", "<leader>bo", dap.repl.open)
