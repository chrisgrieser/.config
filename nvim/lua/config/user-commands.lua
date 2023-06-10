local expand = vim.fn.expand
local fn = vim.fn
local newCommand = vim.api.nvim_create_user_command
--------------------------------------------------------------------------------

-- :I inspect lua code
-- as opposed to `:lua = `, this shows the result in a notification and with
-- syntax highlighting
newCommand("I", function(ctx)
	local str = ctx.args
	if 
		vim.startswith(str, "fn")
		or vim.startswith(str, "bo")
		or vim.startswith(str, "g")
	then
		str = "vim." .. str
	end
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

	for _, client in pairs(clients) do
		if client.name ~= "null-ls" then
			local capAsList = {}
			for key, value in pairs(client.server_capabilities) do
				if value and key:find("Provider") then
					local capability = key:gsub("Provider$", "")
					table.insert(capAsList, "- " .. capability)
				end
			end
			table.sort(capAsList) -- sorts alphabetically
			local msg = client.name .. "\n" .. table.concat(capAsList, "\n")
			vim.notify(msg, vim.log.levels.TRACE, { timeout = 14000 })
			fn.setreg("+", "Capabilities = " .. vim.inspect(client.server_capabilities))
		end
	end
end, {})

-- `:ViewDir` opens the nvim view directory
newCommand("ViewDir", function(_)
	local viewdir = expand(vim.opt.viewdir:get())
	fn.system('open "' .. viewdir .. '"')
end, {})

-- `:PluginDir` opens the nvim data path, where mason and lazy install their stuff
newCommand("PluginDir", function(_) fn.system('open "' .. fn.stdpath("data") .. '"') end, {})
