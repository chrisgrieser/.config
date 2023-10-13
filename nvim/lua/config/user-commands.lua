local fn = vim.fn
local cmd = vim.cmd
local u = require("config.utils")

--------------------------------------------------------------------------------

-- inspect capabilities of current lsp
-- no arg: all LSPs attached to current buffer
-- one arg: name of the LSP
vim.api.nvim_create_user_command("LspCapabilities", function(ctx)
	local selected = ctx.args

	local filter = selected == "" and { bufnr = vim.api.nvim_get_current_buf() }
		or { name = selected }
	local clients = vim.lsp.get_active_clients(filter)

	local out = {}
	for _, client in pairs(clients) do
		local capAsList = {}
		for key, value in pairs(client.server_capabilities) do
			local entry = "- " .. key

			-- indicate manually deactivated capabilities
			if value == false then entry = entry .. " (false)" end
			-- capabilities like `willRename` are listed under the workspace key
			if key == "workspace" then entry = entry .. " " .. vim.inspect(value) end

			table.insert(capAsList, entry)
		end
		table.sort(capAsList) -- sorts alphabetically
		local msg = client.name:upper() .. "\n" .. table.concat(capAsList, "\n")
		table.insert(out, msg)
	end
	u.notify(":LspCapabilities", "trace", table.concat(out, "\n\n"))
end, {
	nargs = "?",
	complete = function()
		local clients = vim.tbl_map(
			function(client) return client.name end,
			require("lspconfig.util").get_managed_clients()
		)
		table.sort(clients)
		return clients
	end,
})

--------------------------------------------------------------------------------

-- shorthand for `.!curl -s` which also creates a new html buffer for syntax highlighting
vim.api.nvim_create_user_command("Curl", function(ctx)
	local url = ctx.args
	local a = vim.api

	-- create scratch buffer
	local ft = url:match("%.(%a)$") or "html" -- could be html or json
	local bufId = a.nvim_create_buf(true, false)
	local bufName = "Curl." .. ft
	local success = pcall(a.nvim_buf_set_name, bufId, bufName)
	if not success then
		u.notify("", "Curl Buffer already exists. ", "warn")
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
