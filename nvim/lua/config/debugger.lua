require("config.utils")
local dap = require("dap")
local dapUI = require("dapui")
--------------------------------------------------------------------------------

-- DAP SETUP
-- INFO: uses dap-names, not mason-names https://github.com/jayp0521/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
require("mason-nvim-dap").setup {
	ensure_installed = {
		"node2",
		"bash",
		-- "python",
	},
	-- one-small-step-for-vimkind not included with mason, but installed as nvim plugin
}

--------------------------------------------------------------------------------
-- CONFIGURATION OF SPECIFIC DEBUGGERS
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

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
dapUI.setup()

--------------------------------------------------------------------------------
-- KEYBINDINGS

keymap("n", "7", dap.toggle_breakpoint)
-- wrap `continue` in this, since the nvim-lua-debugger has to be started
-- separately
keymap("n", "8", function()
	local dapRunning = dap.status() ~= ""
	if not (dapRunning) and bo.filetype == "lua" then
		require("osv").run_this()
	else
		dap.continue()
	end
	wo.number = true
end)


-- selection of dap-commands
keymap("n", "<leader>b", function()
	local selection = {
		"Toggle DAP UI",
		"Terminate",
		"Set Log Point",
		"Clear Breakpoints",
		"Conditional Breakpoint",
		"Step over",
		"Step into",
		"Step out",
		"Run to Cursor",
	}
	vim.ui.select(selection, {prompt = " DAP Command"}, function(choice)
		if not (choice) then return end
		if choice:find("^Launch") then bo.number = true end

		if choice == "Toggle DAP UI" then
			dapUI.toggle()
		elseif choice == "Step over" then
			dap.step_over()
		elseif choice == "Step into" then
			dap.step_into()
		elseif choice == "Step out" then
			dap.step_out()
		elseif choice == "Run to Cursor" then
			dap.run_to_cursor()
		elseif choice == "Clear Breakpoints" then
			dap.clear_breakpoints()
		elseif choice == "Conditional Breakpoint" then
			vim.ui.input({prompt = "Breakpoint condition: "}, function (cond)
				if not(cond) then return end
				dap.set_breakpoint(cond)
			end)
		elseif choice == "Log Point" then
			vim.ui.input({prompt = "Log point message: "}, function(msg)
				if not (msg) then return end
				dap.set_breakpoint(nil, nil, msg)
			end)
		elseif choice == "Terminate" then
			wo.number = false
			dapUI.close()
			dap.terminate()
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
	texthl = "DiagnosticHint",
	numhl = "DiagnosticHint",
})
fn.sign_define("DapLogPoint", {
	text = "",
	texthl = "DiagnosticHint",
	numhl = "DiagnosticHint",
})
fn.sign_define("DapStopped", {
	text = "",
	texthl = "DiagnosticInfo",
	numhl = "DiagnosticInfo",
})
fn.sign_define("DapBreakpointRejected", {
	text = "",
	texthl = "DiagnosticError",
	numhl = "DiagnosticError",
})
