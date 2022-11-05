require("utils")
local dap = require("dap")
--------------------------------------------------------------------------------

require("mason-nvim-dap").setup({
	ensure_installed = {
		"python",
	},
	automatic_setup = true,
})
require("nvim-dap-virtual-text").setup()
-- https://github.com/mxsdev/nvim-dap-vscode-js#setup


--------------------------------------------------------------------------------

keymap("n", "<leader>bb", dap.continue)
keymap("n", "<leader>bp", dap.toggle_breakpoint)
keymap("n", "<leader>bs", dap.step_over)
keymap("n", "<leader>bi", dap.step_into)
keymap("n", "<leader>bo", dap.repl.open)
