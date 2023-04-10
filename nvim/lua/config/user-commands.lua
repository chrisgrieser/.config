local expand = vim.fn.expand
local fn = vim.fn
local newCommand = vim.api.nvim_create_user_command
local u = require("config.utils")

--------------------------------------------------------------------------------

-- :I inspect nvim-lua
newCommand("I", function(ctx)
	local output = vim.inspect(fn.luaeval(ctx.args))
	vim.notify(output, "trace", {
		timeout = 6000, -- ms
		on_open = function(win) -- enable treesitter highlighting in the notification
			local buf = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_set_option(buf, "filetype", "lua")
		end,
	})
end, { nargs = "+" })

-- view capabilities of current lsp
newCommand("LspCapabilities", function()
	local capabilities = vim.lsp.get_active_clients()[1].server_capabilities
	local capAsStr = vim.inspect(capabilities)
	vim.notify(capAsStr, "trace", {
		on_open = function(win)
			local buf = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_set_option(buf, "filetype", "lua")
		end,
		timeout = 6000,
	})
	fn.setreg("+", "capabilities = " .. capAsStr)
end, {})

-- `:SwapDeleteAll` deletes all swap files
newCommand("SwapDeleteAll", function(_)
	local swapdir = u.vimDataDir .. "swap/"
	local out = fn.system([[rm -vf "]] .. swapdir .. [["* ]])
	vim.notify("Deleted:\n" .. out)
end, {})

-- `:ViewDir` opens the nvim view directory
newCommand("ViewDir", function(_)
	local viewdir = expand(vim.opt.viewdir:get())
	fn.system('open "' .. viewdir .. '"')
end, {})

-- `:PluginDir` opens the nvim data path, where mason and lazy install their stuff
newCommand("PluginDir", function(_) fn.system('open "' .. fn.stdpath("data") .. '"') end, {})
