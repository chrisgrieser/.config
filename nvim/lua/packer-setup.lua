-- INFO: file should *not* be named "packer.lua", since `require("packer")`
-- would then be ambigious
local borderStyle = "rounded"
--------------------------------------------------------------------------------

-- auto-install packer if not installed https://github.com/wbthomason/packer.nvim#bootstrapping
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	print("Packer not installed. Installing...")
	vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
	vim.cmd [[packadd packer.nvim]]
end

-- Protected call to prevent error when Packer is not installed
local status_ok, packer = pcall(require, "packer")
if (not status_ok) then return end

-- Load plugins and display packer as popup
packer.startup{
	require("plugin-list").PluginList,
	config = {
		display = {
			open_fn = function() return require('packer.util').float{border = borderStyle} end,
			prompt_border = borderStyle,
			compact = true,
			show_all_info = false,
		},
		snapshot_path = vim.fn.stdpath("config").."/packer-snapshots/",
		autoremove = true, -- remove unused plugins without prompting user
	},
}

packer.install() -- auto-install missing plugins

-- Update [P]lugins
vim.keymap.set("n", "<leader>p", function()
	cmd [[update!]]
	package.loaded["plugin-list"] = nil -- empty the cache for lua
	packer.startup(require("plugin-list").PluginList)
	packer.snapshot("packer-snapshot_" .. os.date("!%Y-%m-%d_%H-%M-%S"))
	packer.sync()
	cmd [[MasonUpdateAll]]
	-- remove oldest snapshot when more than 20
	local snapshotPath = fn.stdpath("config") .. "/packer-snapshots"
	os.execute([[cd ']] .. snapshotPath .. [[' ; ls -t | tail -n +20 | tr '\n' '\0' | xargs -0 rm]])
end)
vim.keymap.set("n", "<leader>P", packer.status)
