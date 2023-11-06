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
	print(table.concat(out, "\n\n"))
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

-- reload lua config
vim.api.nvim_create_user_command(
	"DataDir",
	function() vim.fn.system{"open", vim.fn.stdpath("data")} end,
	{}
)
vim.api.nvim_create_user_command(
	"StateDir",
	function() vim.fn.system{"open", vim.fn.stdpath("state")} end,
	{}
)
