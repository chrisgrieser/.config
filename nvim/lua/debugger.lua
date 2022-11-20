require("utils")
local dap = require("dap")
--------------------------------------------------------------------------------
-- INFO: setup descriptions
-- https://github.com/mxsdev/nvim-dap-vscode-js#setup
--------------------------------------------------------------------------------

-- DAP SETUP
-- INFO: uses dap-names, not mason-names https://github.com/jayp0521/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
require("mason-nvim-dap").setup {
	ensure_installed = {
		"node2",
		"python",
		"bash",
	},
	-- one-small-step-for-vimkind not included with mason, but installed as nvim plugin
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

-- Node2
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#javascript
dap.adapters.node2 = {
	type = "executable",
	command = "node",
	args = {
		fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js"
	}
}

dap.configurations.javascript = {
	{
		name = "Launch",
		type = "node2",
		request = "launch",
		program = "${file}",
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = "inspector",
		console = "integratedTerminal",
	},
	{
		name = "Attach to process",
		type = "node2",
		request = "attach",
		processId = require "dap.utils".pick_process,
	},
}

-- Bash
dap.adapters.bashdb = {
	type = "executable";
	command = fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter";
	name = "bashdb";
}

dap.configurations.sh = {{
	type = "bashdb";
	request = "launch";
	name = "Launch file";
	showDebugOutput = true;
	pathBashdb = fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb";
	pathBashdbLib = fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir";
	trace = true;
	file = "${file}";
	program = "${file}";
	cwd = "${workspaceFolder}";
	pathCat = "cat";
	pathBash = "/bin/bash";
	pathMkfifo = "mkfifo";
	pathPkill = "pkill";
	args = {};
	env = {};
	terminalKind = "integrated";
}}

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
		"Toggle Breakpoint",
		"Step over",
		"Step into",
		"Toggle DAP UI",
	}
	if fn.expand("%:p:h"):find("nvim") and ft == "lua" then
		table.insert(selection, "Launch nvim-debugger")
	elseif ft == "python" then
		table.insert(selection, "Launch debugpy")
	elseif ft == "javascript" or ft == "typescript" then
		table.insert(selection, "Launch node2-debugger")
	elseif ft == "bash" or ft == "sh" then
		table.insert(selection, "Launch bash-debugger")
	end

	vim.ui.select(selection, {prompt = "DAP Command"}, function(choice)
		if not (choice) then return end
		if choice == "Launch nvim-debugger" then
			require("osv").run_this()
		elseif choice == "Launch node2-debugger" then
			vim.notify(" Not implemented yet. ")
		elseif choice == "Launch debugpy" then
			vim.notify(" Not implemented yet. ")
		elseif choice == "Launch bash-debugger" then
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
