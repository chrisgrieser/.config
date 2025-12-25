-- DOCS https://github.com/rvben/rumdl/issues/194#issuecomment-3675558541
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	settings = {
		rumdl = {
			-- less noisy, since `info` diagnostics are configured to not get virtual text
			MD012 = { severity = "info" }, -- multiple blank lines
			MD009 = { severity = "info" }, -- trailing spaces
			MD060 = { severity = "info" }, -- table columns
		},
	},
}
