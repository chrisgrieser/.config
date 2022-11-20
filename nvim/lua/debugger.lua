require("utils")
local dap = require("dap")
--------------------------------------------------------------------------------
-- INFO: setup descriptions
-- https://github.com/mxsdev/nvim-dap-vscode-js#setup
--------------------------------------------------------------------------------

-- DAP SETUP
require("mason-nvim-dap").setup {
	-- INFO: uses dap-names, not mason-names https://github.com/jayp0521/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
	ensure_installed = {
		"node2",
	},
	-- one-step-for-vimkind not included with mason, but installed as nvim plugin
	automatic_setup = true,
}

--------------------------------------------------------------------------------
-- CONFIGURATION OF SPECIFIC DEBUGGERS

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
-- DAP-RELATED PLUGINS
require("nvim-dap-virtual-text").setup()
require("dapui").setup()

--------------------------------------------------------------------------------
-- KEYBINDINGS
keymap("n", "<leader>b", dap.continue)
keymap("n", "<leader>B", function()
	local ft = bo.filetype
	local selection = {
		"Toggle Breakpoint",
		"Step over",
		"Step into",
		"Toggle DAP UI",
	}
	if fn.expand("%:p"):find("nvim") and ft == "lua" then
		table.insert(selection, "Launch nvim-debugger")
	elseif ft == "python" then
		table.insert(selection, "Launch debugpy")
	elseif ft == "javascript" or ft == "typescript" then
		table.insert(selection, "Launch node2-debugger")
	end

	vim.ui.select(selection, {prompt = "DAP Command"}, function(choice)
		if not (choice) then return end
		if choice == "Launch nvim-debugger" then
			require("osv").run_this()
		elseif choice == "Launch node2-debugger" then
			vim.notify(" Not implemented yet. ")
		elseif choice == "Launch debugpy" then
			vim.notify(" Not implemented yet. ")
		elseif choice == "Toggle Breakpoint" then
			dap.toggle_breakpoint()
		elseif choice == "Toggle DAP UI" then
			require("dapui").toggle()
		elseif choice == "Step over" then
			dap.step_over()
		elseif choice == "Step into" then
			dap.step_into()
		end

	end)
end)

--------------------------------------------------------------------------------
-- SIGN-COLUMN ICONS
fn.sign_define("DapBreakpoint", {
	text = "",
	texthl = "DiagnosticHint",
	numhl = "DiagnosticHint",
})
fn.sign_define("DapBreakpointCondition", {
	text = "",
	texthl = "DiagnosticInfo",
	numhl = "DiagnosticInfo",
})
fn.sign_define("DapLogPoint", {
	text = "",
	texthl = "DiagnosticInfo",
	numhl = "DiagnosticInfo",
})
fn.sign_define("DapStopped", {
	text = "",
	texthl = "DiagnosticHint",
	numhl = "DiagnosticHint",
})
fn.sign_define("DapBreakpointRejected", {
	text = "",
	texthl = "DiagnosticError",
	numhl = "DiagnosticError",
})
