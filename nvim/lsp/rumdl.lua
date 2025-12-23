-- DOCS https://github.com/rvben/rumdl/issues/194#issuecomment-3675558541
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	settings = {
		rumdl = {
			-- less noisy, since `info` diagnostics are configured to not get
			-- virtual text
			-- PENDING https://github.com/rvben/rumdl/issues/217
			MD012 = { severity = "info" },
			MD009 = { severity = "info" },
		},
	},
	on_attach = function()
		local orig = vim.lsp.handlers["textDocument/publishDiagnostics"]

		vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
			local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

			if client.name == "rumdl" and result and result.diagnostics then
				Chainsaw(client.name == "rumdl" and result and result.diagnostics) -- 🪚
				for _, d in ipairs(result.diagnostics) do
					if d.code == "MD012" or d.code == "MD009" then
						d.severity = vim.lsp.protocol.DiagnosticSeverity.Info
					end
				end
			end
			return orig(err, result, ctx, config)
		end
	end,
}
