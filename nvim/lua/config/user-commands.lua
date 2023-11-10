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
		local client_info = client.name:upper() .. "\n" .. vim.inspect(client)
		table.insert(out, client_info)
	end
	local msg = table.concat(out, "\n\n")

	-- highlighting in case of noice popup, `once = true` not working as noice
	-- creates multiple temporary windows, therefore deleting afterwards
	local autocmdId = vim.api.nvim_create_autocmd("Filetype", {
		pattern = "noice",
		callback = function() vim.bo.filetype = "lua" end,
	})
	vim.notify(msg)
	vim.defer_fn(function() vim.api.nvim_del_autocmd(autocmdId) end, 100)
end, {
	nargs = "?",
	complete = function()
		local clients = vim.tbl_map(
			function(client) return client.name end,
			vim.lsp.get_active_clients()
		)
		table.sort(clients)
		return clients
	end,
})

--------------------------------------------------------------------------------

vim.api.nvim_create_user_command(
	"DataDir",
	function() vim.fn.system { "open", vim.fn.stdpath("data") } end,
	{}
)
vim.api.nvim_create_user_command(
	"StateDir",
	function() vim.fn.system { "open", vim.fn.stdpath("state") } end,
	{}
)
