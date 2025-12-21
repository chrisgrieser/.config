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
}
