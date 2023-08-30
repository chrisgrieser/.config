local fn = vim.fn
local cmd = vim.cmd
local newCommand = vim.api.nvim_create_user_command
local u = require("config.utils")
--------------------------------------------------------------------------------

vim.cmd.cnoreabbrev("i", "lua =")
vim.cmd.cnoreabbrev("EfmStatus", "checkhealth efmls-configs")


newCommand("LspCapabilities", function()

--------------------------------------------------------------------------------

-- inspect capabilities of current lsp
newCommand("LspCapabilities", function()
	local curBuf = vim.api.nvim_get_current_buf()
	if vim.version().major == 0 and vim.version().minor >= 10 then
		vim.notify("switch to vim.lsp.get_client")
	end
	local clients = vim.lsp.get_active_clients { bufnr = curBuf }

	for _, client in pairs(clients) do
		local capAsList = {}
		for key, _ in pairs(client.server_capabilities) do
			table.insert(capAsList, "- " .. key)
		end
		table.sort(capAsList) -- sorts alphabetically
		local msg = client.name .. "\n" .. table.concat(capAsList, "\n")
		vim.notify(msg, u.trace, { timeout = 14000 })
	end
end, {})

--------------------------------------------------------------------------------

-- shorthand for `.!curl -s` which also creates a new html buffer for syntax highlighting
newCommand("Curl", function(ctx)
	local url = ctx.args
	local a = vim.api

	-- create scratch buffer
	local ft = url:match("%.(%a)$") or "html" -- could be html or json
	local bufId = a.nvim_create_buf(true, false)
	local bufName = "Curl." .. ft
	local success = pcall(a.nvim_buf_set_name, bufId, bufName)
	if not success then
		vim.notify("Curl Buffer already exists. ", u.warn)
		cmd.buffer(bufName)
		return
	end
	cmd.buffer(bufId)

	-- curl
	local timeoutSecs = 8
	local response = fn.system(("curl --silent --max-time %s '%s'"):format(timeoutSecs, url))
	local lines = vim.split(response, "\n")

	-- insert response as lines
	a.nvim_buf_set_option(bufId, "filetype", ft)
	a.nvim_buf_set_lines(bufId, 0, -1, false, lines)

	-- format
	a.nvim_buf_set_option(bufId, "buftype", "nowrite") -- no-write allows lsp to attach
	vim.defer_fn(function() vim.cmd.Format() end, 100) -- formatter.nvim
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
	local filetypes = { "text", "sh", "markdown", "javascript", "json", "lua", "python" }
	vim.ui.select(filetypes, { prompt = "Select Filetype" }, function(choice)
		if not choice then return end
		a.nvim_buf_set_option(bufId, "filetype", choice)

		-- set content from clipboard & format
		local clipb = vim.fn.getreg("+")
		if not clipb or clipb == "" then return end
		local lines = vim.split(clipb, "\n")
		a.nvim_buf_set_lines(bufId, 0, -1, false, lines)
		vim.cmd.Format() -- formatter.nvim
	end)
end, {})

--------------------------------------------------------------------------------

newCommand("Server", function()
	local myServer = vim.fn.serverlist()[2]
	vim.notify(myServer)
end, {})

--------------------------------------------------------------------------------

newCommand("Debug", function()
	local pathExport = "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$$PATH ; "
	local shellCmd = pathExport .. "neovide ./debug/test.lua -- -u ./debug/repro.lua"
	vim.fn.system(shellCmd)
end, {})
