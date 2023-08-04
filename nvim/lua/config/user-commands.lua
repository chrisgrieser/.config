local expand = vim.fn.expand
local fn = vim.fn
local cmd = vim.cmd
local newCommand = vim.api.nvim_create_user_command
--------------------------------------------------------------------------------

-- :I inspect lua code
-- as opposed to `:lua = `, this shows the result in a notification and with
-- syntax highlighting
newCommand("I", function(ctx)
	local output = vim.inspect(fn.luaeval(ctx.args))
	vim.notify(output, vim.log.levels.TRACE, {
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

-- shorthand for `.!curl -s`
-- which also creates a new html buffer for syntax highlighting
newCommand("Curl", function(ctx)
	local url = ctx.args
	local a = vim.api
	local timeoutSecs = 8
	local response = fn.system(("curl --silent --max-time %s '%s'"):format(timeoutSecs, url))
	local lines = vim.split(response, "\n")
	table.insert(lines, 1, "<!-- " .. url .. " -->")

	cmd.enew()
	local ft = url:match("%.(%a)$") or "html" -- could be html, json or other
	a.nvim_buf_set_option(0, "filetype", ft)

	a.nvim_buf_set_option(0, "buftype", "nowrite")
	a.nvim_buf_set_name(0, "curl")
	a.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.lsp.buf.format {}
end, { nargs = 1 })
