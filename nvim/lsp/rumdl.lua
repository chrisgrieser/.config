-- DOCS https://github.com/rvben/rumdl/issues/194#issuecomment-3675558541
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	settings = {
		rumdl = {
			-- less noisy, since `info` diagnostics are configured to not get virtual text
			MD012 = { severity = "info", },
			MD009 = { severity = "info" },
		},
	},
	on_attach = function()
		-- fix the above, PENDING https://github.com/rvben/rumdl/issues/229
		local orig = vim.lsp.handlers["textDocument/diagnostic"]
		vim.lsp.handlers["textDocument/diagnostic"] = function(err, result, ctx, config)
			local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
			if client.name == "rumdl" and result and result.items then
				for _, d in ipairs(result.items) do
					if d.code == "MD012" then d.severity = vim.diagnostic.severity.INFO end
					if d.code == "MD009" then d.severity = vim.diagnostic.severity.INFO end
				end
			end
			return orig(err, result, ctx, config)
		end
	end,
}
