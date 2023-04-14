local expand = vim.fn.expand
local fn = vim.fn
local newCommand = vim.api.nvim_create_user_command
local u = require("config.utils")

--------------------------------------------------------------------------------

-- :I inspect lua code
-- as opposed to `:lua = `, this shows the result in a notification and with
-- syntax highlighting
newCommand("I", function(ctx)
	local str = ctx.args
	if vim.startswith(str, "fn") or vim.startswith(str, "bo") then str = "vim." .. str end
	local output = vim.inspect(fn.luaeval(str))
	vim.notify(output, "trace", {
		timeout = 6000, -- ms
		on_open = function(win) -- enable treesitter highlighting in the notification
			local buf = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_set_option(buf, "filetype", "lua")
		end,
	})
end, { nargs = "+" })

-- inspect capabilities of current lsp
newCommand("LspCapabilities", function()
	local curBuf = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_active_clients { bufnr = curBuf }

	-- ignore null-ls
	local client = clients[1].name ~= "null-ls" and clients[1] or clients[2]

	local capAsList = {}
	for key, value in pairs(client.server_capabilities) do
		if value and key:find("Provider") then
			local capability = key:gsub("Provider$", "")
			table.insert(capAsList, "- " .. capability)
		end
	end
	local msg = "# " .. client.name .. "\n" .. table.concat(capAsList, "\n")
	vim.notify(msg, "trace", {
		on_open = function(win)
			local buf = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
		end,
		timeout = 14000,
	})
	fn.setreg("+", "Capabilities = " .. vim.inspect(client.server_capabilities))
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
