local ns = vim.api.nvim_create_namespace("personalDiagnostics")
local bufnr = bufnr or 0

---@type vim.Diagnostic[]
local diags = {
	{
		lnum = 1,
		col = 1,
		message = "test",
	},
}

--------------------------------------------------------------------------------

vim.diagnostic.set(ns, bufnr, diags)
