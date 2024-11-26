local function getRowsWithMarker()
	local ns = vim.api.nvim_create_namespace("chainsaw.markers")
	return vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
end

vim.notify("🖨️ 🔵")






























-- fffffffffffff
