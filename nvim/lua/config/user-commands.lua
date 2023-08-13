local expand = vim.fn.expand
local fn = vim.fn
local cmd = vim.cmd
local newCommand = vim.api.nvim_create_user_command
local u = require("config.utils")
--------------------------------------------------------------------------------

-- :I inspect lua code
-- as opposed to `:lua = `, this shows the result in a notification and with
-- syntax highlighting
newCommand("I", function(ctx)
	local output = vim.inspect(fn.luaeval(ctx.args))
	vim.notify(output, u.trace, {
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
	if vim.version().major == 0 and vim.version().minor >= 10 then
		vim.notify("switch to vim.lsp.get_client")
	end
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
			vim.notify(msg, u.trace, { timeout = 14000 })
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

--------------------------------------------------------------------------------

-- shorthand for `.!curl -s` which also creates a new html buffer for syntax highlighting
newCommand("Curl", function(ctx)
	local url = ctx.args
	local a = vim.api

	-- create scratch buffer
	local bufId = a.nvim_create_buf(true, false)
	local success = pcall(a.nvim_buf_set_name, bufId, "Curl")
	if not success then 
		vim.notify("Curl Buffer already exists. ", u.warn)
		cmd.buffer("Curl")
		return
	end
	cmd.buffer(bufId)

	-- curl
	local timeoutSecs = 8
	local response = fn.system(("curl --silent --max-time %s '%s'"):format(timeoutSecs, url))
	local lines = vim.split(response, "\n")

	-- insert response as line
	local ft = url:match("%.(%a)$") or "html" -- could be html, json
	a.nvim_buf_set_option(bufId, "filetype", ft)
	table.insert(lines, 1, vim.bo.commentstring:format(" " .. url .. " "))
	a.nvim_buf_set_lines(bufId, 0, -1, false, lines)

	-- format
	a.nvim_buf_set_option(bufId, "buftype", "nowrite") -- no-write allows lsp to attach
	vim.defer_fn(function() vim.lsp.buf.format() end, 100)
end, { nargs = 1 })

-- Scratchpad Buffer
newCommand("Scratch", function()
	local a = vim.api

	-- screate buffer
	local bufId = a.nvim_create_buf(true, false)
	local success = pcall(a.nvim_buf_set_name, bufId, "Scratchpad")
	if not success then 
		vim.notify("Scratchpad already exists. ", u.warn)
		cmd.buffer("Scratchpad")
		return
	end
	a.nvim_buf_set_option(bufId, "buftype", "nowrite") -- no-write allows lsp to attach
	cmd.buffer(bufId)

	-- prompt for filetype
	local filetypes = { "text", "sh", "markdown", "javascript", "json", "lua" }
	vim.ui.select(filetypes, { prompt = "Select Filetype" }, function(choice)
		if not choice then return end
		a.nvim_buf_set_option(bufId, "filetype", choice)

		-- set content from clipboard & format
		local clipb = vim.fn.getreg("+")
		if not clipb or clipb == "" then return end
		local lines = vim.split(clipb, "\n")
		a.nvim_buf_set_lines(bufId, 0, -1, false, lines)
		vim.lsp.buf.format()
	end)
end, {})
